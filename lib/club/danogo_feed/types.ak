use aiken/transaction/credential.{
  Address, Pointer, StakeCredential, from_verification_key,
}
use aiken/transaction/value.{AssetName, PolicyId}
use common/prational.{PRational}
use common/types.{PublicKeyHash, ScriptKeyHash}

pub type ProtocolParams {
  platform_halt: Bool,
  // === club addresses ===
  // club states
  general_state_skh: ScriptKeyHash,
  trading_state_skh: ScriptKeyHash,
  nav_state_skh: ScriptKeyHash,
  deposit_state_skh: ScriptKeyHash,
  withdraw_state_skh: ScriptKeyHash,
  vault_state_skh: ScriptKeyHash,
  // requests
  deposit_pool_skh: ScriptKeyHash,
  withdraw_pool_skh: ScriptKeyHash,
  vault_asset_skh: ScriptKeyHash,
  // operator
  redeem_pool_skh: ScriptKeyHash,
  operator_fee_skh: ScriptKeyHash,
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
  platform_fee_skh: ScriptKeyHash,
  default_stake_key: StakeCredential,
  platform_force_redeem_epoch: Int,
  platform_force_redeem_pkh: PublicKeyHash,
  platform_garbage_collector_deposit_amount: Int,
  platform_garbage_collector_pkh: PublicKeyHash,
  platform_staking_batcher_address: Address,
  // minimum lovelace that LP can deposit
  min_deposit_amount: Int,
  // minimum lovelace that LP can withdraw
  min_withdraw_amount: Int,
  fee_withdraw_amount: Int,
  // max pool number in an epoch, default 1, if assign 0, no pool will be created
  max_deposit_pool_per_epoch: Int,
  max_withdraw_pool_per_epoch: Int,
  // ttl of tx, unit by slot
  tx_ttl: Int,
}

pub type PTokenPrices =
  List<(PolicyId, List<(AssetName, PRational)>)>

pub type PriceFeedDatum {
  // in ms
  created: Int,
  // price is considered valid in window range (in ms):
  // created <= transaction validity range <= expired
  expired: Int,
  // prices: {policyId: {name: price (in lovelace)}}
  token_prices: PTokenPrices,
}

pub type StakeKeyFeedDatum {
  club_policy_id: PolicyId,
  stake_keys: List<ScriptKeyHash>,
  batcher_address: Address,
  total_deposit_pool_supply: Int,
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
    platform_garbage_collector_deposit_amount: 2_000_000,
    platform_garbage_collector_pkh: "",
    platform_staking_batcher_address: from_verification_key(""),
    min_deposit_amount: 100_000_000,
    min_withdraw_amount: 100_000_000,
    fee_withdraw_amount: 2_000_000,
    max_deposit_pool_per_epoch: 1,
    max_withdraw_pool_per_epoch: 1,
    // 5 minutes
    tx_ttl: 5 * 60 * 1000,
  }
}

// gives base object, used for testing
pub fn base_price_feed_datum() -> PriceFeedDatum {
  PriceFeedDatum { created: 0, expired: 1, token_prices: [] }
}

// gives base object, used for testing
pub fn base_stake_key_datum() -> StakeKeyFeedDatum {
  StakeKeyFeedDatum {
    club_policy_id: "",
    stake_keys: [],
    batcher_address: from_verification_key(""),
    total_deposit_pool_supply: 0,
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
