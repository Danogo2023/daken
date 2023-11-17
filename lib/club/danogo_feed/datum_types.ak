use aiken/dict.{Dict}
use aiken/hash.{Blake2b_224, Hash}
use aiken/transaction/credential.{Address, Pointer, Script, StakeCredential}
use aiken/transaction/value.{AssetName, PolicyId}

pub type ProtocolParams {
  platformHalt: Bool,
  // === club addresses ===
  // club states
  generate_state_skh: Hash<Blake2b_224, Script>,
  trading_state_skh: Hash<Blake2b_224, Script>,
  force_state_skh: Hash<Blake2b_224, Script>,
  nav_state_skh: Hash<Blake2b_224, Script>,
  deposit_state_skh: Hash<Blake2b_224, Script>,
  withdraw_state_skh: Hash<Blake2b_224, Script>,
  vault_state_skh: Hash<Blake2b_224, Script>,
  // requests
  deposit_skh: Hash<Blake2b_224, Script>,
  withdraw_skh: Hash<Blake2b_224, Script>,
  vault_skh: Hash<Blake2b_224, Script>,
  // operator
  redeem_skh: Hash<Blake2b_224, Script>,
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
  default_stake_key: StakeCredential,
  platform_force_redeem_epoch: Int,
  platform_force_redeem_pkh: Hash<Blake2b_224, Script>,
  platform_garbage_collector_pkh: Hash<Blake2b_224, Script>,
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
}

pub type PlatformBatcherFeedDatum {
  // defi protocol id
  defi_protocol_id: Int,
  // batcher addresses for that defi id
  batcher_addresses: List<Address>,
}

pub type DefiProtocolFeedDatum {
  // defi protocol id
  id: Int,
  // valid defi addresses
  addresses: List<Address>,
}

// gives base object, used for testing
pub fn base_protocol_params() -> ProtocolParams {
  ProtocolParams {
    platformHalt: False,
    // === club addresses ===
    // club states
    generate_state_skh: "",
    trading_state_skh: "",
    force_state_skh: "",
    nav_state_skh: "",
    deposit_state_skh: "",
    withdraw_state_skh: "",
    vault_state_skh: "",
    // requests
    deposit_skh: "",
    withdraw_skh: "",
    vault_skh: "",
    // operator
    redeem_skh: "",
    operator_fee_skh: "",
    // === club general configs ===
    trading_at_least: 12,
    calc_nav_at_least: 4,
    share_token_price_init: 1_000_000,
    vault_max: 1,
    // === platform configs ===
    platform_fee_percentage: 1,
    default_stake_key: Pointer(0, 0, 0),
    platform_force_redeem_epoch: 0,
    platform_force_redeem_pkh: "",
    platform_garbage_collector_pkh: "",
  }
}

// gives base object, used for testing
pub fn base_price_feed_datum() -> PriceFeedDatum {
  PriceFeedDatum { created: 0, expired: 1, token_prices: dict.new() }
}

// gives base object, used for testing
pub fn base_stake_key_datum() -> StakeKeyFeedDatum {
  StakeKeyFeedDatum { club_policy_id: "", stake_keys: [] }
}

// gives base object, used for testing
pub fn base_platform_batcher_feed_datum() -> PlatformBatcherFeedDatum {
  PlatformBatcherFeedDatum { defi_protocol_id: 0, batcher_addresses: [] }
}

// gives base object, used for testing
pub fn base_defi_protocol_feed_datum() -> DefiProtocolFeedDatum {
  DefiProtocolFeedDatum { id: 0, addresses: [] }
}
