use aiken/bytearray
use aiken/dict.{Dict}
use aiken/list
use aiken/math
use aiken/transaction.{Input}
use aiken/transaction/credential.{ScriptCredential, VerificationKeyCredential}
use aiken/transaction/value.{AssetName}
use bond/types.{
  AskLimit, AskMaking, BidLimit, BidMaking, BondConfig, ConfigLimit,
  ConfigMaking, EpochConfig, Error, EscrowDatum, EscrowInfo, EscrowInfoResult,
  OK,
}

pub fn get_escrow_ref_inputs(
  ref_inputs: List<Input>,
  cfg: BondConfig,
) -> Option<Input> {
  list.find(
    ref_inputs,
    fn(i) {
      when i.output.address.payment_credential is {
        VerificationKeyCredential(_) -> False
        ScriptCredential(k) -> {
          let escrow_asset = value.tokens(i.output.value, cfg.escrow_policy_id)
          k == cfg.escrow_payment_key && dict.size(escrow_asset) == 1 && when
            list.at(dict.values(escrow_asset), 0)
          is {
            Some(v) -> v > 0
            None -> False
          }
        }
      }
    },
  )
}

pub fn get_escrow_info(
  cfg: BondConfig,
  escrow_lovelace: Int,
  escrow_datum: EscrowDatum,
  tx_posix_time: Int,
  current_epoch: Int,
  start_epoch: Int,
  end_epoch: Int,
) -> EscrowInfoResult<EscrowInfo, ByteArray> {
  // Tong tien lai moi epoch Borrower phai tra
  let epoch_rewards_lovelace = value.lovelace_of(escrow_datum.epo_rewards)
  // Tien goc cua toan bo bond phat hanh
  let principal_lovelace = escrow_datum.bond_amount * cfg.bond_face_value
  // Tong tien lai tich luy hien tai cho toan bo bond phat hanh
  let premium_paid_lovelace = escrow_lovelace - principal_lovelace
  // Tong tien lai tich luy hien tai tinh theo epoch cho toan bo bond phat hanh
  // let premium_paid_epoch =
  //   premium_paid_lovelace / epoch_rewards_lovelace
  // Tong epoch phai tra lai tinh den epoch hien tai
  let interest_due_paid_epoch =
    if current_epoch >= end_epoch {
      escrow_datum.duration
    } else {
      current_epoch - start_epoch + 1
    }
  // Tong tien lai Borrower can phai tra tinh den epoch hien tai
  let interest_due_paid_lovelace =
    interest_due_paid_epoch * epoch_rewards_lovelace
  // Tong so epoch ma Borrower tra du tinh tu epoch hien tai
  let interest_level_epoch =
    ( premium_paid_lovelace - interest_due_paid_lovelace ) / epoch_rewards_lovelace
  let interest_lovelace_max = escrow_datum.duration * epoch_rewards_lovelace
  // So epoch con lai cho den khi bond se duoc phep dong
  let closable_in =
    if
    interest_due_paid_epoch >= escrow_datum.duration || escrow_lovelace >= interest_lovelace_max{
    
      end_epoch - current_epoch
    } else {
      interest_level_epoch - escrow_datum.buffer + 1
    }
  if current_epoch > end_epoch || closable_in <= 0 {
    Error("Escrow closable")
  } else {
    // Tien phi Optim thu cua Borrower 3%
    let lend_after_fee = 1 * cfg.basis_points_ref_unit - escrow_datum.otm_fee
    // Tong tien lai lender nhan duoc cua tat ca bond phat hanh khi ket thuc chu ky dao han
    let lender_interest =
      epoch_rewards_lovelace * escrow_datum.duration * lend_after_fee
    // Tong tien lai lender nhan duoc khi den ky dao han cua 1 bond da tru phi cua Optim 3%
    let interest_at_maturity_one_bond_lovelace =
      lender_interest / cfg.basis_points_ref_unit / escrow_datum.bond_amount
    OK(
      EscrowInfo {
        bond_symbol: escrow_datum.bond_symbol,
        token_name: escrow_datum.token_name,
        bond_amount: escrow_datum.bond_amount,
        start_epoch,
        end_epoch,
        // Tong tien goc + lai cua 1 bond theo lai suat Optim ma lender nhan duoc 
        received_at_maturity_one_bond: interest_at_maturity_one_bond_lovelace + cfg.bond_face_value,
        // So ngay den ky dao han cua bond
        day_to_maturity: get_day_to_maturity(
          tx_posix_time,
          end_epoch,
          cfg.epoch_config,
        ),
      },
    )
  }
}

pub fn get_price_of_bond(
  received_at_maturity: Int,
  day_to_maturity: Int,
  yield: Int,
  basis_points_ref_unit: Int,
) -> Int {
  received_at_maturity * basis_points_ref_unit * basis_points_ref_unit / (
    basis_points_ref_unit * basis_points_ref_unit + yield * basis_points_ref_unit * day_to_maturity / 365
  )
}

pub fn get_milliseconds_of_day(epoch_config: EpochConfig) -> Int {
  epoch_config.epoch_length * 86400000 / epoch_config.epoch_length_base
}

pub fn get_day_to_maturity(
  tx_time: Int,
  end_epoch: Int,
  epoch_config: EpochConfig,
) -> Int {
  let maturity_time: Int =
    relative_epoch_to_posix_time_start(end_epoch, epoch_config)
  if tx_time > maturity_time {
    0
  } else {
    let time_of_day = get_milliseconds_of_day(epoch_config)
    let diff_time = maturity_time - tx_time
    let maturity_day = diff_time / time_of_day
    if diff_time % time_of_day == 0 {
      maturity_day
    } else {
      maturity_day + 1
    }
  }
}

pub fn posix_time_to_relative_epoch(
  posix_time: Int,
  epoch_config: EpochConfig,
) -> Int {
  ( posix_time - epoch_config.epoch_boundary ) / epoch_config.epoch_length + epoch_config.epoch_boundary_as_epoch
}

pub fn relative_epoch_to_posix_time_start(
  relative_epoch: Int,
  epoch_config: EpochConfig,
) -> Int {
  ( relative_epoch - epoch_config.epoch_boundary_as_epoch ) * epoch_config.epoch_length + epoch_config.epoch_boundary
}

pub fn relative_epoch_to_posix_time_end(
  relative_epoch: Int,
  epoch_config: EpochConfig,
) -> Int {
  relative_epoch_to_posix_time_start(relative_epoch, epoch_config) + epoch_config.epoch_length
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

pub fn datum_yield_limit_valid(conf: ConfigLimit, val: Int) -> Bool {
  (math.clamp(val, conf.bond.basis_points_min, conf.bond.basis_points_max) == val)?
}

pub fn datum_yield_making_valid(conf: ConfigMaking, val: Int) -> Bool {
  (math.clamp(val, conf.bond.basis_points_min, conf.bond.basis_points_max) == val)?
}

pub fn datum_epoch_valid(
  out_from_epoch: Int,
  out_to_epoch: Int,
  out_quantity: Int,
) -> Bool {
  (out_to_epoch >= out_from_epoch)? && (out_quantity > 0)?
}

pub fn datum_ask_limit_compare(all: AskLimit, alr: AskLimit) {
  (all.owner_payment_key == alr.owner_payment_key)? && (all.owner_stake_key == alr.owner_stake_key)? && (all.requested_yield == alr.requested_yield)?
}

pub fn datum_bid_limit_compare(bll: BidLimit, blr: BidLimit) {
  (bll.owner_payment_key == blr.owner_payment_key)? && (bll.owner_stake_key == blr.owner_stake_key)? && (bll.from_epoch == blr.from_epoch)? && (bll.to_epoch == blr.to_epoch)? && (bll.requested_yield == blr.requested_yield)?
}

pub fn datum_ask_making_compare(aml: AskMaking, amr: AskMaking) {
  (aml.owner_payment_key == amr.owner_payment_key)? && (aml.owner_stake_key == amr.owner_stake_key)? && (aml.requested_yield == amr.requested_yield)? && (aml.bid_sc == amr.bid_sc)? && (aml.margin == amr.margin)?
}

pub fn datum_bid_making_compare(bml: BidMaking, bmr: BidMaking) {
  (bml.owner_payment_key == bmr.owner_payment_key)? && (bml.owner_stake_key == bmr.owner_stake_key)? && (bml.from_epoch == bmr.from_epoch)? && (bml.to_epoch == bmr.to_epoch)? && (bml.requested_yield == bmr.requested_yield)? && (bml.ask_sc == bmr.ask_sc)? && (bml.margin == bmr.margin)?
}
