use aiken/bytearray
use aiken/dict.{Dict}
use aiken/hash.{Blake2b_256, Hash}
use aiken/interval.{
  Finite, Interval, IntervalBound, NegativeInfinity, PositiveInfinity,
}
use aiken/transaction.{
  Datum, Input, Output, OutputReference, Transaction, TransactionId,
}
use aiken/transaction/credential.{
  Address, Inline, ScriptCredential, VerificationKeyCredential, from_script,
  from_verification_key,
}
use aiken/transaction/value.{AssetName, PolicyId, Value}
use bond/common.{get_day_to_maturity, posix_time_to_relative_epoch}
use bond/types.{
  AskLimit, AskMaking, BidLimit, BidMaking, BondConfig, ConfigLimit,
  ConfigMaking, EpochConfig, EscrowDatum, ExchangeConfigLimit,
  ExchangeConfigMaking, PaymentDatum,
}
use common/types.{PublicKeyHash, SlotConfigNetwork} as common_types

pub fn tx(
  inputs: List<Input>,
  reference_inputs: List<Input>,
  outputs: List<Output>,
  extra_signatories: Option<List<PublicKeyHash>>,
  datums: Option<Dict<Hash<Blake2b_256, Data>, Data>>,
  validity_after: Option<Int>,
  validity_before: Option<Int>,
) -> Transaction {
  let tx =
    Transaction {
      inputs,
      reference_inputs,
      outputs,
      fee: value.zero(),
      mint: value.to_minted_value(
        value.from_asset(#"000000", #"000020e05363726970744f776e6572", -1),
      ),
      certificates: [],
      withdrawals: dict.new(),
      validity_range: Interval {
        lower_bound: IntervalBound {
          bound_type: when validity_after is {
            Some(x) -> Finite(x)
            _ -> NegativeInfinity
          },
          is_inclusive: True,
        },
        upper_bound: IntervalBound {
          bound_type: when validity_before is {
            Some(x) -> Finite(x)
            _ -> PositiveInfinity
          },
          is_inclusive: True,
        },
      },
      extra_signatories: when extra_signatories is {
        Some(s) -> s
        _ ->
          [#"00010213"]
      },
      redeemers: dict.new(),
      datums: when datums is {
        Some(d) -> d
        _ -> dict.new()
      },
      id: TransactionId { hash: #"" },
    }
  tx
}

pub fn get_epoch_config_preview() -> EpochConfig {
  EpochConfig {
    year_to_epoch: 73,
    epoch_boundary: 1647899091000,
    epoch_boundary_as_epoch: 328,
    epoch_length: 1800000,
    epoch_length_base: 432000000,
  }
}

pub fn get_epoch_config_mainnet() -> EpochConfig {
  EpochConfig {
    year_to_epoch: 73,
    epoch_boundary: 1647899091000,
    epoch_boundary_as_epoch: 328,
    epoch_length: 432000000,
    epoch_length_base: 432000000,
  }
}

pub fn get_slot_config_network_preview() -> SlotConfigNetwork {
  SlotConfigNetwork {
    zero_time: 1666656000000,
    zero_slot: 0,
    slot_length: 1000,
  }
}

pub fn get_slot_config_network_mainnet() -> SlotConfigNetwork {
  SlotConfigNetwork {
    zero_time: 1596059091000,
    zero_slot: 4492800,
    slot_length: 1000,
  }
}

fn get_bond_config_preview() -> BondConfig {
  BondConfig {
    escrow_payment_key: get_escrow_address_hash(),
    escrow_policy_id: get_escrow_policy_id(),
    basis_points_ref_unit: 10000,
    basis_points_min: 1,
    basis_points_max: 9999,
    one_ada_2_lovelace: 1000000,
    bond_face_value: 100000000,
    epoch_config: get_epoch_config_preview(),
  }
}

fn get_bond_config_mainnet() -> BondConfig {
  BondConfig {
    escrow_payment_key: get_escrow_address_hash(),
    escrow_policy_id: get_escrow_policy_id(),
    basis_points_ref_unit: 10000,
    basis_points_min: 1,
    basis_points_max: 9999,
    one_ada_2_lovelace: 1000000,
    bond_face_value: 100000000,
    epoch_config: get_epoch_config_mainnet(),
  }
}

fn get_exchange_config() -> ExchangeConfigLimit {
  ExchangeConfigLimit {
    address: get_exchange_address(),
    buyer_fee: 100,
    seller_fee: 100,
    tx_buy_valid_slot: Some(3 * 60),
  }
}

fn get_exchange_making_config() -> ExchangeConfigMaking {
  ExchangeConfigMaking {
    address: get_exchange_address(),
    maker_fee: 50,
    taker_fee: 100,
    tx_buy_valid_slot: Some(3 * 60),
  }
}

pub fn get_config_limit_preview() -> ConfigLimit {
  ConfigLimit {
    bond: get_bond_config_preview(),
    exchange: get_exchange_config(),
    slot_config_network: get_slot_config_network_preview(),
  }
}

pub fn get_config_limit_mainnet() -> ConfigLimit {
  ConfigLimit {
    bond: get_bond_config_mainnet(),
    exchange: get_exchange_config(),
    slot_config_network: get_slot_config_network_mainnet(),
  }
}

pub fn get_config_making_preview() -> ConfigMaking {
  ConfigMaking {
    bond: get_bond_config_preview(),
    exchange: get_exchange_making_config(),
    slot_config_network: get_slot_config_network_preview(),
  }
}

pub fn get_config_making_mainnet() -> ConfigMaking {
  ConfigMaking {
    bond: get_bond_config_mainnet(),
    exchange: get_exchange_making_config(),
    slot_config_network: get_slot_config_network_mainnet(),
  }
}

pub fn get_bond_policy_id() -> PolicyId {
  bytearray.from_string(
    @"53fb41609e208f1cd3cae467c0b9abfc69f1a552bf9a90d51665a4d6",
  )
}

pub fn get_not_bond_policy_id() -> PolicyId {
  bytearray.from_string(
    @"4b9ae3978af62cf98dcc3b9aecc3dbbd2f59fa06b55e1f443e3c7c81",
  )
}

pub fn get_escrow_policy_id() -> PolicyId {
  bytearray.from_string(
    @"5f1dd3192cbdaa2c1a91560a6147466efb18d33a5d6516b266ce6b6f",
  )
}

pub fn get_not_escrow_policy_id() -> PolicyId {
  bytearray.from_string(
    @"87aa0c11bb8f94d523a74fe7badded9c4908d1a65c8a6443e9f98db4",
  )
}

pub fn get_fraud_address() -> Address {
  from_verification_key(get_fraud_address_hash())
}

pub fn get_fraud_address_hash() -> ByteArray {
  #"010200"
}

pub fn get_seller_address() -> Address {
  from_verification_key(get_seller_address_hash())
}

pub fn get_seller_address_hash() -> ByteArray {
  #"010203"
}

pub fn get_buyer_address_scripthash() -> Address {
  from_script(get_buyer_address_hash())
}

pub fn get_buyer_address() -> Address {
  from_verification_key(get_buyer_address_hash())
}

pub fn get_buyer_address_hash() -> ByteArray {
  #"010204"
}

pub fn get_ask_sc_address() -> Address {
  from_script(get_ask_sc_address_hash())
}

fn get_ask_sc_address_hash() -> ByteArray {
  #"040505"
}

pub fn get_bid_sc_address() -> Address {
  from_script(get_bid_sc_address_hash())
}

fn get_bid_sc_address_hash() -> ByteArray {
  #"040506"
}

pub fn get_exchange_address() -> Address {
  from_verification_key(get_exchange_address_hash())
}

pub fn get_exchange_address_hash() -> ByteArray {
  #"040507"
}

pub fn get_bond_id_1() -> AssetName {
  bytearray.from_string(
    @"97b2efcc14587d6bd648252b17108ba3cb628273fa45080572d920df1f53e934",
  )
}

pub fn get_bond_id_2() -> AssetName {
  bytearray.from_string(
    @"b66d1cef461fb3a0616737ebe8056985a659129292215ef7484f0d37fcafb93e",
  )
}

pub fn get_og_lender_1() -> ByteArray {
  bytearray.from_string(
    @"e7e620338c24165d8496444f91b949f45372d9f60dc8a79bbbdd063c",
  )
}

pub type EscrowFullInfo {
  start_epoch: Int,
  duration_epoch: Int,
  maturity_epoch: Int,
  bond_amount: Int,
  principal: Int,
  epo_rewards: Int,
  premium_paid_lovelace: Int,
  premium_paid_epoch: Int,
  otm_fee: Int,
  current_epoch: Int,
  tx_time: Int,
  interest_buffer: Int,
  interest_due_paid: Int,
  interest_level_lovelace: Int,
  interest_level_epoch: Int,
  interest_at_maturity_one_bond: Int,
  received_at_maturity_one_bond: Int,
  day_to_maturity: Int,
}

pub fn calc_escrow_full_info(
  bond_config: BondConfig,
  escrow_lovelace: Int,
  escrow_datum: EscrowDatum,
  tx_posix_time: Int,
) -> EscrowFullInfo {
  let current_epoch =
    posix_time_to_relative_epoch(tx_posix_time, bond_config.epoch_config)
  let start_epoch =
    escrow_datum.start + bond_config.epoch_config.epoch_boundary_as_epoch
  let end_epoch = start_epoch + escrow_datum.duration
  // Tong tien goc voi thong tin so luong bond trong datum
  let principal_lovelace =
    escrow_datum.bond_amount * bond_config.bond_face_value
  // Tong tien lai dang giu trong escrow
  let premium_paid_lovelace = escrow_lovelace - principal_lovelace
  // So tien lai borrower phai tra moi epoch cho tong so bond phat hanh
  let epoch_rewards_lovelace = value.lovelace_of(escrow_datum.epo_rewards)
  // Tong so tien lai borrower phai tra den current epoch
  let interest_due_paid_lovelace =
    if current_epoch >= end_epoch {
      escrow_datum.duration
    } else {
      current_epoch - start_epoch + 1
    } * epoch_rewards_lovelace
  // Tong so tien lai theo epoch da duoc borrower thanh toan
  let premium_paid_epoch = premium_paid_lovelace / epoch_rewards_lovelace
  // Tong so tien lai dang tra thua
  let interest_level_lovelace =
    premium_paid_lovelace - interest_due_paid_lovelace
  // Tong so tien lai dang tra thua tinh theo epoch
  let interest_level_epoch = interest_level_lovelace / epoch_rewards_lovelace
  // Tien phi Optim thu cua Borrower 3%
  let lend_after_fee =
    1 * bond_config.basis_points_ref_unit - escrow_datum.otm_fee
  // Tong tien lai lender nhan duoc khi den ky dao han cua 1 bond
  let interest_at_maturity_one_bond =
    epoch_rewards_lovelace * escrow_datum.duration * lend_after_fee / bond_config.basis_points_ref_unit / escrow_datum.bond_amount
  EscrowFullInfo {
    start_epoch,
    duration_epoch: escrow_datum.duration,
    maturity_epoch: end_epoch,
    bond_amount: escrow_datum.bond_amount,
    principal: principal_lovelace,
    epo_rewards: epoch_rewards_lovelace,
    premium_paid_lovelace,
    premium_paid_epoch,
    otm_fee: escrow_datum.otm_fee,
    current_epoch,
    tx_time: tx_posix_time,
    interest_buffer: escrow_datum.buffer,
    interest_due_paid: interest_due_paid_lovelace,
    interest_level_lovelace,
    interest_level_epoch,
    interest_at_maturity_one_bond,
    // Tong tien goc + lai cua 1 bond theo lai suat Optim ma lender nhan duoc 
    received_at_maturity_one_bond: interest_at_maturity_one_bond + bond_config.bond_face_value,
    day_to_maturity: get_day_to_maturity(
      tx_posix_time,
      end_epoch,
      bond_config.epoch_config,
    ),
  }
}

pub fn get_escrow_datum(
  asset_name: AssetName,
  bond_amount: Int,
  epo_rewards: Int,
  duration: Int,
  start: Int,
) -> EscrowDatum {
  EscrowDatum {
    epo_rewards: value.from_lovelace(epo_rewards),
    duration,
    bond_symbol: get_bond_policy_id(),
    token_name: asset_name,
    bond_amount,
    buffer: 6,
    otm_fee: 300,
    og_lender: get_og_lender_1(),
    start,
  }
}

pub fn get_escrow_address_hash() -> ByteArray {
  #"010210"
}

pub fn get_escrow_address() -> Address {
  from_script(get_escrow_address_hash())
}

pub fn get_escrow_address_hash_unexpect() -> ByteArray {
  #"010211"
}

pub fn get_escrow_address_unexpect() -> Address {
  from_script(get_escrow_address_hash_unexpect())
}

pub fn get_input_escrow(
  address: Address,
  escrow_policy_id: PolicyId,
  escrow_asset_name: AssetName,
  escrow_qty: Int,
  lovelace: Int,
  datum: Datum,
) -> Input {
  Input {
    output_reference: OutputReference {
      transaction_id: TransactionId { hash: #"00" },
      output_index: 0,
    },
    output: Output {
      address,
      value: value.add(
        value.from_lovelace(lovelace),
        escrow_policy_id,
        escrow_asset_name,
        escrow_qty,
      ),
      datum,
      reference_script: None,
    },
  }
}

pub fn gen_ask_limit_datum(owner: Address, requested_yield: Int) -> AskLimit {
  AskLimit {
    owner_payment_key: when owner.payment_credential is {
      VerificationKeyCredential(vk) -> vk
      ScriptCredential(sc) -> sc
    },
    owner_stake_key: when owner.stake_credential is {
      Some(Inline(VerificationKeyCredential(vk))) -> Some(vk)
      _ -> None
    },
    requested_yield,
  }
}

pub fn gen_bid_limit_datum(
  owner: Address,
  from_epoch: Int,
  to_epoch: Int,
  quantity: Int,
  requested_yield: Int,
) -> BidLimit {
  BidLimit {
    owner_payment_key: when owner.payment_credential is {
      VerificationKeyCredential(vk) -> vk
      ScriptCredential(sh) -> sh
    },
    owner_stake_key: when owner.stake_credential is {
      Some(Inline(VerificationKeyCredential(vk))) -> Some(vk)
      _ -> None
    },
    from_epoch,
    to_epoch,
    quantity,
    requested_yield,
  }
}

pub fn gen_ask_making_datum(owner: Address, requested_yield: Int) -> AskMaking {
  AskMaking {
    owner_payment_key: when owner.payment_credential is {
      VerificationKeyCredential(vk) -> vk
      ScriptCredential(sh) -> sh
    },
    owner_stake_key: when owner.stake_credential is {
      Some(Inline(VerificationKeyCredential(vk))) -> Some(vk)
      _ -> None
    },
    requested_yield,
    bid_sc: get_bid_sc_address_hash(),
    margin: 1,
  }
}

pub fn gen_tampered_ask_making_datum(
  owner: Address,
  requested_yield: Int,
) -> AskMaking {
  AskMaking {
    owner_payment_key: when owner.payment_credential is {
      VerificationKeyCredential(vk) -> vk
      ScriptCredential(sh) -> sh
    },
    owner_stake_key: when owner.stake_credential is {
      Some(Inline(VerificationKeyCredential(vk))) -> Some(vk)
      _ -> None
    },
    requested_yield,
    bid_sc: get_fraud_address_hash(),
    margin: 1,
  }
}

pub fn gen_bid_making_datum(
  owner: Address,
  from_epoch: Int,
  to_epoch: Int,
  quantity: Int,
  requested_yield: Int,
) -> BidMaking {
  BidMaking {
    owner_payment_key: when owner.payment_credential is {
      VerificationKeyCredential(vk) -> vk
      ScriptCredential(sh) -> sh
    },
    owner_stake_key: when owner.stake_credential is {
      Some(Inline(VerificationKeyCredential(vk))) -> Some(vk)
      _ -> None
    },
    from_epoch,
    to_epoch,
    quantity,
    requested_yield,
    ask_sc: get_ask_sc_address_hash(),
    margin: 1,
  }
}

pub fn gen_tampered_bid_making_datum(
  owner: Address,
  from_epoch: Int,
  to_epoch: Int,
  quantity: Int,
  requested_yield: Int,
) -> BidMaking {
  BidMaking {
    owner_payment_key: when owner.payment_credential is {
      VerificationKeyCredential(vk) -> vk
      ScriptCredential(sh) -> sh
    },
    owner_stake_key: when owner.stake_credential is {
      Some(Inline(VerificationKeyCredential(vk))) -> Some(vk)
      _ -> None
    },
    from_epoch,
    to_epoch,
    quantity,
    requested_yield,
    ask_sc: get_fraud_address_hash(),
    margin: 1,
  }
}

pub fn gen_input(
  address: Address,
  lovelace: Int,
  assets: Option<Value>,
  datum: Datum,
) -> Input {
  Input {
    output_reference: get_output_reference(),
    output: Output {
      address,
      value: when assets is {
        Some(x) -> value.merge(value.from_lovelace(lovelace), x)
        _ -> value.from_lovelace(lovelace)
      },
      datum,
      reference_script: None,
    },
  }
}

pub fn get_output_reference() -> OutputReference {
  OutputReference {
    transaction_id: TransactionId { hash: #"00" },
    output_index: 0,
  }
}

pub fn get_payment_datum() -> PaymentDatum {
  PaymentDatum { output_reference: get_output_reference() }
}

pub fn gen_output(
  address: Address,
  lovelace: Int,
  assets: Option<Value>,
  datum: Datum,
) -> Output {
  Output {
    address,
    value: when assets is {
      Some(x) -> value.merge(value.from_lovelace(lovelace), x)
      _ -> value.from_lovelace(lovelace)
    },
    datum,
    reference_script: None,
  }
}
