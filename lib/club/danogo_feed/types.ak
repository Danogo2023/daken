use aiken/dict.{Dict}
use aiken/hash.{Blake2b_224, Hash}
use aiken/transaction/credential.{
  Address, Pointer, Script, StakeCredential, from_verification_key,
}
use aiken/transaction/value.{AssetName, PolicyId}

pub type ProtocolParams {
  platform_halt: Bool,
  // === club addresses ===
  // club states
  general_state_skh: Hash<Blake2b_224, Script>,
  trading_state_skh: Hash<Blake2b_224, Script>,
  nav_state_skh: Hash<Blake2b_224, Script>,
  deposit_state_skh: Hash<Blake2b_224, Script>,
  withdraw_state_skh: Hash<Blake2b_224, Script>,
  vault_state_skh: Hash<Blake2b_224, Script>,
  // requests
  deposit_pool_skh: Hash<Blake2b_224, Script>,
  withdraw_pool_skh: Hash<Blake2b_224, Script>,
  vault_asset_skh: Hash<Blake2b_224, Script>,
  // operator
  redeem_pool_skh: Hash<Blake2b_224, Script>,
  operator_fee_skh: Hash<Blake2b_224, Script>,
  // === club general configs ===
  // default: 12
  trading_at_least: Int,
  // default: 4
  calc_nav_at_least: Int,
  // default: 1_000_000 (lovelace)
  share_token_price_init: Int,
  vault_max: Int,
  // === platform configs ===
  // percentage, 0001 -> 9999: 0.01% -> 99.99%
  platform_fee_percentage: Int,
  platform_fee_skh: Hash<Blake2b_224, Script>,
  default_stake_key: StakeCredential,
  platform_force_redeem_epoch: Int,
  platform_force_redeem_pkh: Hash<Blake2b_224, Script>,
  platform_garbage_collector_pkh: Hash<Blake2b_224, Script>,
  platform_staking_batcher_address: Address,
  // minimum lovelace that LP can deposit
  min_deposit_amount: Int,
  // minimum lovelace that LP can withdraw
  min_withdraw_amount: Int,
}

pub type PriceFeedDatum {
  // in ms
  created: Int,
  // price is considered valid in window range (in ms):
  // created <= transaction validity range <= expired
  expired: Int,
  // prices: {policyId: {name: price (in lovelace)}}
  token_prices: Dict<PolicyId, Dict<AssetName, Int>>,
}

pub type StakeKeyFeedDatum {
  club_policy_id: PolicyId,
  stake_keys: List<Hash<Blake2b_224, Script>>,
  batcher_address: Address,
}

pub type DefiProtocolActionFeedDatum {
  // defi protocol id
  id: Int,
  // action key
  action_key: ByteArray,
  // valid defi addresses
  addresses: List<Address>,
  // batcher corresponding to this action
  batcher_address: Option<Address>,
}

// gives base object, used for testing
pub fn base_protocol_params() -> ProtocolParams {
  ProtocolParams {
    platform_halt: False,
    // === club addresses ===
    // club states
    general_state_skh: "",
    trading_state_skh: "",
    nav_state_skh: "",
    deposit_state_skh: "",
    withdraw_state_skh: "",
    vault_state_skh: "",
    // requests
    deposit_pool_skh: "",
    withdraw_pool_skh: "",
    vault_asset_skh: "",
    // operator
    redeem_pool_skh: "",
    operator_fee_skh: "",
    // === club general configs ===
    trading_at_least: 12,
    calc_nav_at_least: 4,
    share_token_price_init: 1_000_000,
    vault_max: 1,
    // === platform configs ===
    platform_fee_percentage: 100,
    platform_fee_skh: "",
    default_stake_key: Pointer(0, 0, 0),
    platform_force_redeem_epoch: 0,
    platform_force_redeem_pkh: "",
    platform_garbage_collector_pkh: "",
    platform_staking_batcher_address: from_verification_key(""),
    min_deposit_amount: 100_000_000,
    min_withdraw_amount: 100_000_000,
  }
}

// gives base object, used for testing
pub fn base_price_feed_datum() -> PriceFeedDatum {
  PriceFeedDatum { created: 0, expired: 1, token_prices: dict.new() }
}

// gives base object, used for testing
pub fn base_stake_key_datum() -> StakeKeyFeedDatum {
  StakeKeyFeedDatum {
    club_policy_id: "",
    stake_keys: [],
    batcher_address: from_verification_key(""),
  }
}

// gives base object, used for testing
pub fn base_defi_protocol_action_feed_datum() -> DefiProtocolActionFeedDatum {
  DefiProtocolActionFeedDatum {
    id: 0,
    action_key: "",
    addresses: [],
    batcher_address: None,
  }
}
