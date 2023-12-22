use aiken/bytearray
use aiken/dict.{Dict}
use aiken/list
use aiken/math
use aiken/time.{PosixTime}
use aiken/transaction.{Input}
use aiken/transaction/credential.{ScriptCredential, VerificationKeyCredential}
use aiken/transaction/value.{AssetName}
use bond/types.{
  AskLimit, AskMaking, BidLimit, BidLimitMulti, BidMaking, BondType, DanogoBond,
  Error, EscrowConfig, EscrowDatum, EscrowInfo, EscrowInfoResult, OK, OptimBond,
  PlatformConfig,
}
use common/time.{
  Basis, BasisPoints, DayNum, EpochConfig, EpochTime, get_milliseconds_of_day,
  relative_epoch_to_posix_time_start,
} as common_time
use common/types.{Lovelace} as common_types
use common/util.{find_while}

pub fn get_escrow_ref_inputs(
  ref_inputs: List<Input>,
  cfg: EscrowConfig,
) -> (Option<Input>, Option<BondType>) {
  find_while(
    ref_inputs,
    (None, None),
    fn(i, z) {
      when i.output.address.payment_credential is {
        VerificationKeyCredential(_) -> (False, z)
        ScriptCredential(k) ->
          when dict.get(cfg, k) is {
            Some((escrow_pid, bond_type)) ->
              when dict.values(value.tokens(i.output.value, escrow_pid)) is {
                [q] if q > 0 -> (True, (Some(i), Some(bond_type)))
                _ -> (False, z)
              }
            _ -> (False, z)
          }
      }
    },
  )
}

pub fn get_escrow_info(
  cfg: PlatformConfig,
  escrow_balance: Lovelace,
  escrow_dt: EscrowDatum,
  tx_time: PosixTime,
  epo_curr: EpochTime,
  epo_start: EpochTime,
  epo_end: EpochTime,
) -> EscrowInfoResult<EscrowInfo, ByteArray> {
  // Tong tien lai moi epoch Borrower phai tra
  let epoch_rewards: Lovelace = value.lovelace_of(escrow_dt.epo_rewards)
  // Tien goc cua toan bo bond phat hanh
  let principal: Lovelace = escrow_dt.bond_amount * cfg.bond_face_value
  // Tong tien lai tich luy hien tai cho toan bo bond phat hanh
  let premium_paid: Lovelace = escrow_balance - principal
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
    if due_paid_epo >= escrow_dt.duration || escrow_balance >= interest_max {
      epo_end - epo_curr
    } else {
      interest_level - escrow_dt.buffer + 1
    }
  if epo_curr > epo_end || closable_in <= 0 {
    Error("Escrow closable")
  } else {
    // Tien phi Optim thu cua Borrower 3%
    let lender_rate: Basis = cfg.basis.base - escrow_dt.otm_fee
    // Tong tien lai lender nhan duoc cua tat ca bond phat hanh khi ket thuc chu ky dao han
    let lender_interest: Lovelace =
      epoch_rewards * escrow_dt.duration * lender_rate
    // Tong tien lai lender nhan duoc khi den ky dao han cua 1 bond da tru phi cua Optim 3%
    let interest_at_maturity: Lovelace =
      lender_interest / cfg.basis.base / escrow_dt.bond_amount
    OK(
      EscrowInfo {
        bond_symbol: escrow_dt.bond_symbol,
        token_name: escrow_dt.token_name,
        bond_amount: escrow_dt.bond_amount,
        start_epoch: epo_start,
        end_epoch: epo_end,
        // Tong tien goc + lai cua 1 bond theo lai suat Optim ma lender nhan duoc 
        received_at_maturity_one_bond: interest_at_maturity + cfg.bond_face_value,
        // So ngay den ky dao han cua bond
        day_to_maturity: get_day_to_maturity(tx_time, epo_end, cfg.epoch),
      },
    )
  }
}

pub fn get_price_of_bond(
  received_at_maturity: Lovelace,
  day_to_maturity: DayNum,
  yield: Basis,
  base: Basis,
) -> Lovelace {
  received_at_maturity * base * base / (
    base * base + yield * base * day_to_maturity / 365
  )
}

pub fn get_day_to_maturity(
  tx_time: PosixTime,
  epo_end: EpochTime,
  cfg: EpochConfig,
) -> DayNum {
  let maturity_time: PosixTime =
    relative_epoch_to_posix_time_start(epo_end, cfg)
  if tx_time > maturity_time {
    0
  } else {
    let time_of_day = get_milliseconds_of_day(cfg)
    let diff_time = maturity_time - tx_time
    let maturity_day = diff_time / time_of_day
    if diff_time % time_of_day == 0 {
      maturity_day
    } else {
      maturity_day + 1
    }
  }
}

pub fn bond_assets(
  left: Dict<AssetName, Int>,
  right: Dict<AssetName, Int>,
) -> Dict<AssetName, Int> {
  dict.union_with(
    left,
    right,
    fn(_, v1, v2) { Some(v1 + v2) },
    bytearray.compare,
  )
}

pub fn datum_yield_limit_valid(basis: BasisPoints, v: Int) -> Bool {
  (math.clamp(v, basis.min, basis.max) == v)?
}

pub fn datum_yield_making_valid(basis: BasisPoints, v: Int) -> Bool {
  (math.clamp(v, basis.min, basis.max) == v)?
}

pub fn datum_epoch_valid(
  epo_from: EpochTime,
  epo_to: EpochTime,
  out_qty: Int,
) -> Bool {
  and {
    (epo_to >= epo_from)?,
    (out_qty > 0)?,
  }
}

pub fn datum_ask_limit_compare(all: AskLimit, alr: AskLimit) {
  and {
    (all.owner_vk == alr.owner_vk)?,
    (all.owner_sk == alr.owner_sk)?,
    (all.requested_yield == alr.requested_yield)?,
  }
}

pub fn datum_bid_limit_compare(bll: BidLimit, blr: BidLimit) {
  and {
    (bll.owner_vk == blr.owner_vk)?,
    (bll.owner_sk == blr.owner_sk)?,
    (bll.from_epoch == blr.from_epoch)?,
    (bll.to_epoch == blr.to_epoch)?,
    (bll.requested_yield == blr.requested_yield)?,
  }
}

pub fn datum_bid_limit_multi_compare(bll: BidLimitMulti, blr: BidLimitMulti) {
  and {
    (bll.owner_vk == blr.owner_vk)?,
    (bll.owner_sk == blr.owner_sk)?,
    (bll.from_epoch == blr.from_epoch)?,
    (bll.to_epoch == blr.to_epoch)?,
    (bll.requested_yield == blr.requested_yield)?,
    (list.difference(bll.bond_types, blr.bond_types) == [])?,
  }
}

test compare_list_1() {
  // [DanogoBond, OptimBond] == [_ 121([]), 122([])]
  // [OptimBond, DanogoBond] == [_ 122([]), 121([])]
  [DanogoBond, OptimBond] != [OptimBond, DanogoBond]
}

pub fn datum_ask_making_compare(aml: AskMaking, amr: AskMaking) {
  and {
    (aml.owner_vk == amr.owner_vk)?,
    (aml.owner_sk == amr.owner_sk)?,
    (aml.requested_yield == amr.requested_yield)?,
    (aml.bid_sc == amr.bid_sc)?,
    (aml.margin == amr.margin)?,
  }
}

pub fn datum_bid_making_compare(bml: BidMaking, bmr: BidMaking) {
  and {
    (bml.owner_vk == bmr.owner_vk)?,
    (bml.owner_sk == bmr.owner_sk)?,
    (bml.from_epoch == bmr.from_epoch)?,
    (bml.to_epoch == bmr.to_epoch)?,
    (bml.requested_yield == bmr.requested_yield)?,
    (bml.ask_sc == bmr.ask_sc)?,
    (bml.margin == bmr.margin)?,
  }
}
