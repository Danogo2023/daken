use aiken/dict
use aiken/list
use aiken/math
use aiken/time.{PosixTime} as aiken_time
use aiken/transaction.{Input}
use aiken/transaction/credential.{ScriptCredential}
use aiken/transaction/value
use bond/types.{
  AskLimit, AskMaking, BidLimit, BidLimitMulti, BidMaking, BondConfig,
  ConfigLimit, ConfigMaking, EscrowDatum, EscrowInfo,
}
use bond/utils.{get_day_to_maturity}
use common/pvalue
use common/time.{Basis, BasisPoints, EpochTime}
use common/types.{Error, Lovelace, OK, Result} as common_types

pub fn get_escrow_ref(ref_inputs: List<Input>, cfg: BondConfig) -> Option<Input> {
  list.find(
    ref_inputs,
    fn(i) {
      when i.output.address.payment_credential is {
        ScriptCredential(k) -> and {
            k == cfg.escrow_payment_key,
            when
              dict.values(value.tokens(i.output.value, cfg.escrow_policy_id))
            is {
              [q] if q > 0 -> True
              _ -> False
            },
          }
        _ -> False
      }
    },
  )
}

pub fn get_escrow_info(
  cfg: BondConfig,
  escrow_bal: Lovelace,
  escrow_dt: EscrowDatum,
  tx_time: PosixTime,
  epo_curr: EpochTime,
  epo_start: EpochTime,
  epo_end: EpochTime,
) -> Result<EscrowInfo, String> {
  // Tong tien lai moi epoch Borrower phai tra
  let epoch_rewards: Lovelace =
    value.lovelace_of(pvalue.to_value(escrow_dt.epo_rewards))
  // Tien goc cua toan bo bond phat hanh
  let principal: Lovelace = escrow_dt.bond_amount * cfg.bond_face_value
  // Tong tien lai tich luy hien tai cho toan bo bond phat hanh
  let premium_paid: Lovelace = escrow_bal - principal
  // Tong tien lai tich luy hien tai tinh theo epoch cho toan bo bond phat hanh
  // let premium_paid_epoch =
  //   premium_paid / epoch_rewards
  // Tong epoch phai tra lai tinh den epoch hien tai
  let due_paid_epo: EpochTime =
    if epo_curr >= epo_end {
      escrow_dt.duration
    } else {
      epo_curr - epo_start + 1
    }
  // Tong tien lai Borrower can phai tra tinh den epoch hien tai
  let due_paid: Lovelace = due_paid_epo * epoch_rewards
  // Tong so epoch ma Borrower tra du tinh tu epoch hien tai
  let interest_level: EpochTime = ( premium_paid - due_paid ) / epoch_rewards
  let interest_max: Lovelace = escrow_dt.duration * epoch_rewards
  // So epoch con lai cho den khi bond se duoc phep dong
  let closable_in: EpochTime =
    if or {
      due_paid_epo >= escrow_dt.duration,
      escrow_bal >= interest_max,
    } {
      epo_end - epo_curr
    } else {
      interest_level - escrow_dt.buffer + 1
    }
  if or {
    epo_curr > epo_end,
    closable_in <= 0,
  } {
    Error(@"Bond closable")
  } else {
    // Tien phi Optim thu cua Borrower 3%
    let lender_rate: Basis = cfg.basis_points_ref_unit - escrow_dt.otm_fee
    // Tong tien lai lender nhan duoc cua tat ca bond phat hanh khi ket thuc chu ky dao han
    let lender_interest: Lovelace =
      epoch_rewards * escrow_dt.duration * lender_rate
    // Tong tien lai lender nhan duoc khi den ky dao han cua 1 bond da tru phi cua Optim 3%
    let interest_at_maturity: Lovelace =
      lender_interest / cfg.basis_points_ref_unit / escrow_dt.bond_amount
    OK(
      EscrowInfo {
        bond_symbol: escrow_dt.bond_symbol,
        token_name: escrow_dt.token_name,
        bond_amount: escrow_dt.bond_amount,
        start_epoch: epo_start,
        end_epoch: epo_end,
        // Tong tien goc + lai cua 1 bond theo lai suat Optim ma lender nhan duoc 
        value_at_maturity: interest_at_maturity + cfg.bond_face_value,
        // So ngay den ky dao han cua bond
        day_to_maturity: get_day_to_maturity(tx_time, epo_end, cfg.epoch_config),
      },
    )
  }
}

pub fn yield_limit_valid(conf: ConfigLimit, val: Basis) -> Bool {
  (math.clamp(val, conf.bond.basis_points_min, conf.bond.basis_points_max) == val)?
}

pub fn yield_making_valid(conf: ConfigMaking, val: Basis) -> Bool {
  (math.clamp(val, conf.bond.basis_points_min, conf.bond.basis_points_max) == val)?
}

pub fn epoch_valid(epo_from: EpochTime, epo_to: EpochTime, out_qty: Int) -> Bool {
  and {
    (epo_from >= 0)?, 
    (epo_to >= epo_from)?,
    (out_qty > 0)?,
  }
}

pub fn ask_limit_valid(left: AskLimit, right: AskLimit) -> Bool {
  and {
    (left.owner_vk == right.owner_vk)?,
    (left.owner_sk == right.owner_sk)?,
    (left.requested_yield == right.requested_yield)?,
  }
}

pub fn bid_limit_valid(left: BidLimit, right: BidLimit) -> Bool {
  and {
    (left.owner_vk == right.owner_vk)?,
    (left.owner_sk == right.owner_sk)?,
    (left.from_epoch == right.from_epoch)?,
    (left.to_epoch == right.to_epoch)?,
    (left.requested_yield == right.requested_yield)?,
  }
}

pub fn ask_making_valid(left: AskMaking, right: AskMaking) -> Bool {
  and {
    (left.owner_vk == right.owner_vk)?,
    (left.owner_sk == right.owner_sk)?,
    (left.requested_yield == right.requested_yield)?,
    (left.bid_sc == right.bid_sc)?,
    (left.margin == right.margin)?,
  }
}

pub fn bid_making_valid(left: BidMaking, right: BidMaking) -> Bool {
  and {
    (left.owner_vk == right.owner_vk)?,
    (left.owner_sk == right.owner_sk)?,
    (left.from_epoch == right.from_epoch)?,
    (left.to_epoch == right.to_epoch)?,
    (left.requested_yield == right.requested_yield)?,
    (left.ask_sc == right.ask_sc)?,
    (left.margin == right.margin)?,
  }
}

pub fn yield_valid(basis: BasisPoints, v: Int) -> Bool {
  (math.clamp(v, basis.min, basis.max) == v)?
}

pub fn bid_limit_multi_valid(left: BidLimitMulti, right: BidLimitMulti) -> Bool {
  and {
    (left.owner_vk == right.owner_vk)?,
    (left.owner_sk == right.owner_sk)?,
    (left.from_epoch == right.from_epoch)?,
    (left.to_epoch == right.to_epoch)?,
    (left.requested_yield == right.requested_yield)?,
    (list.difference(left.bond_types, right.bond_types) == [])?,
    (left.epoch_type == right.epoch_type)?,
  }
}
