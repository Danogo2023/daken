use aiken/bytearray
use aiken/dict.{Dict}
use aiken/list
use aiken/string
use aiken/time.{PosixTime} as aiken_time
use aiken/transaction.{DatumHash, InlineDatum, Input, NoDatum}
use aiken/transaction/credential.{ScriptCredential}
use aiken/transaction/value.{AssetName}
use bond/types.{
  BondType, EscrowConfig, EscrowDatum, EscrowInfo, EscrowRef, PlatformConfig,
} as bond_types
use common/string.{bconcat_1, bconcat_3, to_unit} as common_string
use common/time.{
  Basis, DayNum, EpochConfig, EpochTime, Milliseconds, get_milliseconds_of_day,
  relative_epoch_to_posix_time_start,
} as common_time
use common/types.{AssetUnit, Datums, Error, Lovelace, OK, Result}
use common/util.{find_while}

pub fn head_escrow_ref(
  platform_cfg: PlatformConfig,
  escrow_cfg: EscrowConfig,
  tx_ref_inputs: List<Input>,
  tx_datums: Datums,
  bond_types: List<BondType>,
  tx_time: PosixTime,
  epo_curr: EpochTime,
) -> Result<EscrowRef, String> {
  find_escrow_ref_with(
    escrow_cfg,
    tx_ref_inputs,
    tx_datums,
    bond_types,
    fn(escrow_ref, bond_unit, escrow_dt, escrow_input, bond_type) {
      find_escrow_ref_finalize(
        platform_cfg,
        escrow_ref,
        bond_unit,
        escrow_dt,
        escrow_input,
        bond_type,
        tx_time,
        epo_curr,
        True,
      )
    },
  )
}

pub fn list_escrow_ref(
  platform_cfg: PlatformConfig,
  escrow_cfg: EscrowConfig,
  tx_ref_inputs: List<Input>,
  tx_datums: Datums,
  bond_types: List<BondType>,
  tx_time: PosixTime,
  epo_curr: EpochTime,
) -> Result<EscrowRef, String> {
  find_escrow_ref_with(
    escrow_cfg,
    tx_ref_inputs,
    tx_datums,
    bond_types,
    fn(escrow_ref, bond_unit, escrow_dt, escrow_input, bond_type) {
      if !dict.has_key(escrow_ref, bond_unit) {
        find_escrow_ref_finalize(
          platform_cfg,
          escrow_ref,
          bond_unit,
          escrow_dt,
          escrow_input,
          bond_type,
          tx_time,
          epo_curr,
          False,
        )
      } else {
        (True, Error(@"Escrow reference input is duplicate"))
      }
    },
  )
}

fn find_escrow_ref_with(
  escrow_cfg: EscrowConfig,
  tx_ref_inputs: List<Input>,
  tx_datums: Datums,
  bond_types: List<BondType>,
  with: fn(EscrowRef, AssetUnit, EscrowDatum, Input, BondType) ->
    (Bool, Result<EscrowRef, String>),
) -> Result<EscrowRef, String> {
  find_while(
    tx_ref_inputs,
    OK(dict.new()),
    fn(i, z) {
      when i.output.address.payment_credential is {
        ScriptCredential(k) ->
          when dict.get(escrow_cfg, k) is {
            Some((escrow_nft_pid, bond_type)) ->
              if list.has(bond_types, bond_type) {
                when
                  value.tokens(i.output.value, escrow_nft_pid) |> dict.to_list
                is {
                  [(n, q)] ->
                    if q == 1 {
                      expect OK(escrow_ref) = z
                      let data =
                        when i.output.datum is {
                          NoDatum -> None
                          DatumHash(h) -> dict.get(tx_datums, h)
                          InlineDatum(d) -> Some(d)
                        }
                      when data is {
                        Some(dt) -> {
                          expect escrow_dt: EscrowDatum = dt
                          if n == escrow_dt.token_name {
                            with(
                              escrow_ref,
                              bytearray.from_string(
                                to_unit(
                                  escrow_dt.bond_symbol,
                                  @".",
                                  escrow_dt.token_name,
                                ),
                              ),
                              escrow_dt,
                              i,
                              bond_type,
                            )
                          } else {
                            (
                              True,
                              Error(
                                bconcat_1(
                                  bconcat_1(
                                    @"escrow policy id ",
                                    escrow_nft_pid,
                                    @" asset name invalid (expected: ",
                                  ),
                                  escrow_dt.token_name,
                                  bconcat_1(@", actual: ", n, @")"),
                                ),
                              ),
                            )
                          }
                        }
                        _ -> (True, Error(@"Escrow datum can't be None"))
                      }
                    } else {
                      (
                        True,
                        Error(
                          bconcat_3(
                            @"escrow asset ",
                            to_unit(escrow_nft_pid, @".", n),
                            bconcat_3(
                              @" qty invalid (expected: 1, actual: ",
                              string.from_int(q),
                              @")",
                            ),
                          ),
                        ),
                      )
                    }
                  _ ->
                    (
                      True,
                      Error(
                        bconcat_1(
                          @"escrow policy id ",
                          escrow_nft_pid,
                          @" asset invalid",
                        ),
                      ),
                    )
                }
              } else {
                (False, z)
              }
            _ -> (False, z)
          }
        _ -> (False, z)
      }
    },
  )
}

fn find_escrow_ref_finalize(
  platform_cfg: PlatformConfig,
  escrow_ref: EscrowRef,
  bond_unit: AssetUnit,
  escrow_dt: EscrowDatum,
  escrow_input: Input,
  bond_type: BondType,
  tx_time: PosixTime,
  epo_curr: EpochTime,
  break: Bool,
) -> (Bool, Result<EscrowRef, String>) {
  // Tong tien lai moi epoch Borrower phai tra
  let escrow_epo_rewards = value.lovelace_of(escrow_dt.epo_rewards)
  if and {
    (escrow_dt.bond_amount > 0)?,
    (escrow_epo_rewards > 0)?,
  } {
    let escrow_bal: Lovelace = value.lovelace_of(escrow_input.output.value)
    when
      get_escrow_info(
        platform_cfg,
        bond_unit,
        escrow_bal,
        escrow_dt,
        escrow_epo_rewards,
        tx_time,
        epo_curr,
      )
    is {
      OK(escrow_info) ->
        (
          break,
          OK(
            dict.insert(
              escrow_ref,
              bond_unit,
              (escrow_input, escrow_dt, bond_type, escrow_bal, escrow_info),
              bytearray.compare,
            ),
          ),
        )
      Error(s) -> (True, Error(s))
    }
  } else {
    (True, Error(bconcat_1(@"bond ", bond_unit, @" datum invalid")))
  }
}

pub fn get_escrow_info(
  platform_cfg: PlatformConfig,
  bond_unit: AssetUnit,
  escrow_bal: Lovelace,
  escrow_dt: EscrowDatum,
  escrow_epo_rewards: Lovelace,
  tx_time: PosixTime,
  epo_curr: EpochTime,
) -> Result<EscrowInfo, String> {
  let escrow_epo_start: EpochTime =
    escrow_dt.start + platform_cfg.epoch.epoch_boundary_as_epoch
  let escrow_epo_end: EpochTime = escrow_epo_start + escrow_dt.duration
  // Tong epoch phai tra lai tinh den epoch hien tai
  let escrow_due_paid_epo: EpochTime =
    if epo_curr >= escrow_epo_end {
      escrow_dt.duration
    } else {
      epo_curr - escrow_epo_start + 1
    }
  // Tong tien lai Borrower can phai tra tinh den epoch hien tai
  let escrow_due_paid: Lovelace = escrow_due_paid_epo * escrow_epo_rewards
  // Tien goc cua toan bo bond phat hanh
  let escrow_principal: Lovelace =
    escrow_dt.bond_amount * platform_cfg.bond_face_value
  let escrow_bal_min: Lovelace = escrow_principal + escrow_due_paid
  if (escrow_bal >= escrow_bal_min)? {
    // Tong tien lai tich luy hien tai cho toan bo bond phat hanh
    let premium_paid: Lovelace = escrow_bal - escrow_principal
    // Tong tien lai tich luy hien tai tinh theo epoch cho toan bo bond phat hanh
    // let epo_premium_paid: EpochTime = premium_paid / escrow_epo_rewards
    // Tong so epoch ma Borrower tra du tinh tu epoch hien tai
    let interest_level: EpochTime =
      ( premium_paid - escrow_due_paid ) / escrow_epo_rewards
    let interest_max: Lovelace = escrow_epo_rewards * escrow_dt.duration
    // So epoch con lai cho den khi bond se duoc phep dong
    let closable_in: EpochTime =
      if or {
        escrow_due_paid_epo >= escrow_dt.duration,
        escrow_bal >= interest_max,
      } {
        escrow_epo_end - epo_curr
      } else {
        interest_level - escrow_dt.buffer + 1
      }
    if or {
      epo_curr > escrow_epo_end,
      closable_in <= 0,
    } {
      Error(bconcat_1(@"Bond ", bond_unit, @" closable"))
    } else {
      // Tien phi Optim thu cua Borrower 3%
      let lender_rate: Basis = platform_cfg.basis.base - escrow_dt.otm_fee
      // Tong tien lai lender nhan duoc cua tat ca bond phat hanh khi ket thuc chu ky dao han
      let lender_interest: Lovelace =
        escrow_epo_rewards * escrow_dt.duration * lender_rate
      // Tong tien lai lender nhan duoc khi den ky dao han cua 1 bond da tru phi cua Optim 3%
      let interest_at_maturity: Lovelace =
        lender_interest / platform_cfg.basis.base / escrow_dt.bond_amount
      OK(
        EscrowInfo {
          bond_symbol: escrow_dt.bond_symbol,
          token_name: escrow_dt.token_name,
          bond_amount: escrow_dt.bond_amount,
          start_epoch: escrow_epo_start,
          end_epoch: escrow_epo_end,
          // Tong tien goc + lai cua 1 bond theo lai suat Optim ma lender nhan duoc 
          value_at_maturity: interest_at_maturity + platform_cfg.bond_face_value,
          // So ngay den ky dao han cua bond
          day_to_maturity: get_day_to_maturity(
            tx_time,
            escrow_epo_end,
            platform_cfg.epoch,
          ),
        },
      )
    }
  } else {
    Error(bconcat_1(@"Bond ", bond_unit, @" missing interest"))
  }
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
    let time_of_day: Milliseconds = get_milliseconds_of_day(cfg)
    let diff_time: Milliseconds = maturity_time - tx_time
    let maturity_day: DayNum = diff_time / time_of_day
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
