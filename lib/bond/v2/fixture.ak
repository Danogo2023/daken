use aiken/bytearray
use aiken/dict.{Dict}
use aiken/hash.{Blake2b_256, Hash}
use aiken/interval.{
  Finite, Interval, IntervalBound, NegativeInfinity, PositiveInfinity,
}
use aiken/time.{PosixTime}
use aiken/transaction.{
  Datum, Input, Output, OutputReference, Transaction, TransactionId,
}
use aiken/transaction/credential.{
  Address, Inline, ScriptCredential, VerificationKeyCredential, from_script,
  from_verification_key,
}
use aiken/transaction/value.{AssetName, PolicyId, Value}
use bond/types.{
  AskLimit, AskMaking, BidLimit, BidLimitMulti, BidMaking, BondConfigLimit,
  BondConfigMaking, BondType, DanogoBond, EscrowConfig, EscrowDatum,
  ExchangeConfigLimit, ExchangeConfigMaking, PaymentDatum, PlatformConfig,
}
use bond/v2/constraint.{get_day_to_maturity}
use common/time.{
  Basis, DayNum, EpochTime, SlotConfig, get_basis_points_config,
  get_epoch_config_mainnet, get_epoch_config_preview,
  posix_time_to_relative_epoch,
} as common_time
use common/types.{Lovelace, PublicKeyHash} as common_types

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

pub fn get_slot_config_preview() -> SlotConfig {
  SlotConfig { zero_time: 1_666_656_000_000, zero_slot: 0, slot_length: 1_000 }
}

pub fn get_slot_config_mainnet() -> SlotConfig {
  SlotConfig {
    zero_time: 1_596_059_091_000,
    zero_slot: 4_492_800,
    slot_length: 1_000,
  }
}

fn get_exchange_config() -> ExchangeConfigLimit {
  ExchangeConfigLimit {
    address: get_exchange_address(),
    buyer_fee: 100,
    seller_fee: 100,
    tx_buy_ttl: Some(3 * 60),
  }
}

fn get_exchange_making_config() -> ExchangeConfigMaking {
  ExchangeConfigMaking {
    address: get_exchange_address(),
    maker_fee: 50,
    taker_fee: 100,
    tx_buy_ttl: Some(3 * 60),
  }
}

pub fn get_platform_config_preview() -> PlatformConfig {
  PlatformConfig {
    slot: get_slot_config_preview(),
    epoch: get_epoch_config_preview(),
    basis: get_basis_points_config(),
    one_ada_2_lovelace: 1_000_000,
    bond_face_value: 100_000_000,
  }
}

pub fn get_platform_config_mainnet() -> PlatformConfig {
  PlatformConfig {
    slot: get_slot_config_mainnet(),
    epoch: get_epoch_config_mainnet(),
    basis: get_basis_points_config(),
    one_ada_2_lovelace: 1_000_000,
    bond_face_value: 100_000_000,
  }
}

pub fn get_escrow_config() -> EscrowConfig {
  dict.new()
    |> dict.insert(
         get_escrow_policy_id(),
         (get_escrow_address_hash(), DanogoBond),
         bytearray.compare,
       )
}

pub fn get_config_limit_preview() -> BondConfigLimit {
  BondConfigLimit {
    platform: get_platform_config_preview(),
    escrow: get_escrow_config(),
    exchange: get_exchange_config(),
  }
}

pub fn get_config_limit_mainnet() -> BondConfigLimit {
  BondConfigLimit {
    platform: get_platform_config_mainnet(),
    escrow: get_escrow_config(),
    exchange: get_exchange_config(),
  }
}

pub fn get_config_making_preview() -> BondConfigMaking {
  BondConfigMaking {
    platform: get_platform_config_preview(),
    escrow: get_escrow_config(),
    exchange: get_exchange_making_config(),
  }
}

pub fn get_config_making_mainnet() -> BondConfigMaking {
  BondConfigMaking {
    platform: get_platform_config_mainnet(),
    escrow: get_escrow_config(),
    exchange: get_exchange_making_config(),
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
  start_epoch: EpochTime,
  duration_epoch: EpochTime,
  maturity_epoch: EpochTime,
  bond_amount: Int,
  principal: Lovelace,
  epo_rewards: Lovelace,
  premium_paid_lovelace: Lovelace,
  premium_paid_epoch: EpochTime,
  otm_fee: Basis,
  current_epoch: EpochTime,
  tx_time: PosixTime,
  interest_buffer: EpochTime,
  interest_due_paid: EpochTime,
  interest_level_lovelace: Lovelace,
  interest_level_epoch: EpochTime,
  interest_at_maturity_one_bond: Lovelace,
  received_at_maturity_one_bond: Lovelace,
  day_to_maturity: DayNum,
}

pub fn calc_escrow_full_info(
  cfg: PlatformConfig,
  escrow_balance: Lovelace,
  escrow_dt: EscrowDatum,
  tx_time: PosixTime,
) -> EscrowFullInfo {
  let epo_current: EpochTime = posix_time_to_relative_epoch(tx_time, cfg.epoch)
  let epo_start: EpochTime = escrow_dt.start + cfg.epoch.epoch_boundary_as_epoch
  let epo_end: EpochTime = epo_start + escrow_dt.duration
  // Tong tien goc voi thong tin so luong bond trong datum
  let principal: Lovelace = escrow_dt.bond_amount * cfg.bond_face_value
  // Tong tien lai dang giu trong escrow
  let premium_paid: Lovelace = escrow_balance - principal
  // So tien lai borrower phai tra moi epoch cho tong so bond phat hanh
  let epo_rewards: Lovelace = value.lovelace_of(escrow_dt.epo_rewards)
  // Tong so tien lai borrower phai tra den current epoch
  let epo_due_paid: EpochTime =
    if epo_current >= epo_end {
      escrow_dt.duration
    } else {
      epo_current - epo_start + 1
    } * epo_rewards
  // Tong so tien lai theo epoch da duoc borrower thanh toan
  let premium_paid_epoch: EpochTime = premium_paid / epo_rewards
  // Tong so tien lai dang tra thua
  let interest_level: Lovelace = premium_paid - epo_due_paid
  // Tong so tien lai dang tra thua tinh theo epoch
  let interest_level_epoch: EpochTime = interest_level / epo_rewards
  // Tien phi Optim thu cua Borrower 3%
  let lender_rate: Basis = cfg.basis.base - escrow_dt.otm_fee
  // Tong tien lai lender nhan duoc khi den ky dao han cua 1 bond
  let interest_at_maturity: Lovelace =
    epo_rewards * escrow_dt.duration * lender_rate / cfg.basis.base / escrow_dt.bond_amount
  EscrowFullInfo {
    start_epoch: epo_start,
    duration_epoch: escrow_dt.duration,
    maturity_epoch: epo_end,
    bond_amount: escrow_dt.bond_amount,
    principal,
    epo_rewards,
    premium_paid_lovelace: premium_paid,
    premium_paid_epoch,
    otm_fee: escrow_dt.otm_fee,
    current_epoch: epo_current,
    tx_time,
    interest_buffer: escrow_dt.buffer,
    interest_due_paid: epo_due_paid,
    interest_level_lovelace: interest_level,
    interest_level_epoch,
    interest_at_maturity_one_bond: interest_at_maturity,
    // Tong tien goc + lai cua 1 bond theo lai suat Optim ma lender nhan duoc 
    received_at_maturity_one_bond: interest_at_maturity + cfg.bond_face_value,
    day_to_maturity: get_day_to_maturity(tx_time, epo_end, cfg.epoch),
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
  escrow_pid: PolicyId,
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
        escrow_pid,
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
    owner_vk: when owner.payment_credential is {
      VerificationKeyCredential(vk) -> vk
      ScriptCredential(sc) -> sc
    },
    owner_sk: when owner.stake_credential is {
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
    owner_vk: when owner.payment_credential is {
      VerificationKeyCredential(vk) -> vk
      ScriptCredential(sh) -> sh
    },
    owner_sk: when owner.stake_credential is {
      Some(Inline(VerificationKeyCredential(vk))) -> Some(vk)
      _ -> None
    },
    from_epoch,
    to_epoch,
    quantity,
    requested_yield,
  }
}

pub fn gen_bid_limit_multi_datum(
  owner: Address,
  from_epoch: Int,
  to_epoch: Int,
  quantity: Int,
  requested_yield: Int,
  bond_types: List<BondType>,
) -> BidLimitMulti {
  BidLimitMulti {
    owner_vk: when owner.payment_credential is {
      VerificationKeyCredential(vk) -> vk
      ScriptCredential(sh) -> sh
    },
    owner_sk: when owner.stake_credential is {
      Some(Inline(VerificationKeyCredential(vk))) -> Some(vk)
      _ -> None
    },
    from_epoch,
    to_epoch,
    quantity,
    requested_yield,
    bond_types,
  }
}

pub fn gen_ask_making_datum(owner: Address, requested_yield: Int) -> AskMaking {
  AskMaking {
    owner_vk: when owner.payment_credential is {
      VerificationKeyCredential(vk) -> vk
      ScriptCredential(sh) -> sh
    },
    owner_sk: when owner.stake_credential is {
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
    owner_vk: when owner.payment_credential is {
      VerificationKeyCredential(vk) -> vk
      ScriptCredential(sh) -> sh
    },
    owner_sk: when owner.stake_credential is {
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
    owner_vk: when owner.payment_credential is {
      VerificationKeyCredential(vk) -> vk
      ScriptCredential(sh) -> sh
    },
    owner_sk: when owner.stake_credential is {
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
    owner_vk: when owner.payment_credential is {
      VerificationKeyCredential(vk) -> vk
      ScriptCredential(sh) -> sh
    },
    owner_sk: when owner.stake_credential is {
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
