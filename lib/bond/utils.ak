use aiken/bytearray
use aiken/dict.{Dict}
use aiken/time.{PosixTime} as aiken_time
use aiken/transaction.{DatumHash, InlineDatum, Input, NoDatum, Transaction}
use aiken/transaction/credential.{ScriptCredential}
use aiken/transaction/value.{AssetName}
use bond/types.{BondType, EscrowConfig, EscrowDatum, EscrowInfo, PlatformConfig}
use common/time.{
  Basis, DayNum, EpochConfig, EpochTime, get_milliseconds_of_day,
  relative_epoch_to_posix_time_start,
} as common_time
use common/types.{Error, Lovelace, OK, Result} as common_types
use common/util.{find_while}

pub fn head_escrow_ref(
  ref_inputs: List<Input>,
  cfg: EscrowConfig,
) -> (Option<Input>, Option<BondType>) {
  find_while(
    ref_inputs,
    (None, None),
    fn(i, z) {
      when i.output.address.payment_credential is {
        ScriptCredential(k) ->
          when dict.get(cfg, k) is {
            Some((escrow_pid, bond_type)) ->
              when dict.values(value.tokens(i.output.value, escrow_pid)) is {
                [q] if q > 0 -> (True, (Some(i), Some(bond_type)))
                _ -> (False, z)
              }
            _ -> (False, z)
          }
        _ -> (False, z)
      }
    },
  )
}

pub fn list_escrow_ref(
  cfg: EscrowConfig,
  tx: Transaction,
) -> Result<Dict<ByteArray, (Input, EscrowDatum, BondType)>, String> {
  find_while(
    tx.reference_inputs,
    OK(dict.new()),
    fn(i, z) {
      when i.output.address.payment_credential is {
        ScriptCredential(k) ->
          when dict.get(cfg, k) is {
            Some((escrow_pid, bond_type)) ->
              when dict.values(value.tokens(i.output.value, escrow_pid)) is {
                [q] if q > 0 -> {
                  expect OK(r) = z
                  let data =
                    when i.output.datum is {
                      NoDatum -> None
                      DatumHash(h) -> dict.get(tx.datums, h)
                      InlineDatum(d) -> Some(d)
                    }
                  when data is {
                    Some(dt) -> {
                      expect escrow_dt: EscrowDatum = dt
                      let escrow_key =
                        bytearray.concat(
                          escrow_dt.bond_symbol,
                          escrow_dt.bond_symbol,
                        )
                      if !dict.has_key(r, escrow_key) {
                        (
                          False,
                          OK(
                            dict.insert(
                              r,
                              escrow_key,
                              (i, escrow_dt, bond_type),
                              bytearray.compare,
                            ),
                          ),
                        )
                      } else {
                        (True, Error(@"Escrow reference input is duplicate"))
                      }
                    }
                    _ -> (True, Error(@"Escrow datum can't be None"))
                  }
                }
                _ -> (False, z)
              }
            _ -> (False, z)
          }
        _ -> (False, z)
      }
    },
  )
}

pub fn get_escrow_info(
  cfg: PlatformConfig,
  escrow_bal: Lovelace,
  escrow_dt: EscrowDatum,
  tx_time: PosixTime,
  epo_curr: EpochTime,
  epo_start: EpochTime,
  epo_end: EpochTime,
) -> Result<EscrowInfo, String> {
  // Tong tien lai moi epoch Borrower phai tra
  let epoch_rewards: Lovelace = value.lovelace_of(escrow_dt.epo_rewards)
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
    if due_paid_epo >= escrow_dt.duration || escrow_bal >= interest_max {
      epo_end - epo_curr
    } else {
      interest_level - escrow_dt.buffer + 1
    }
  if epo_curr > epo_end || closable_in <= 0 {
    Error(@"Bond closable")
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
        value_at_maturity: interest_at_maturity + cfg.bond_face_value,
        // So ngay den ky dao han cua bond
        day_to_maturity: get_day_to_maturity(tx_time, epo_end, cfg.epoch),
      },
    )
  }
}

pub fn get_price_of_bond(
  value_at_maturity: Lovelace,
  day_to_maturity: DayNum,
  yield: Basis,
  base: Basis,
) -> Lovelace {
  value_at_maturity * base * base / (
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
