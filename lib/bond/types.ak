use aiken/dict.{Dict}
use aiken/transaction.{Output, OutputReference}
use aiken/transaction/credential.{Address, StakeCredential}
use aiken/transaction/value.{AssetName, Value}
use common/types.{SlotConfigNetwork}

pub type EpochConfig {
  // 1 year = 365 days / 5 days per epoch = 73 epoch. default: 73
  year_to_epoch: Int,
  // default: 1_647_899_091_000
  epoch_boundary: Int,
  // default: epoch 327+1
  epoch_boundary_as_epoch: Int,
  // Each Cardano epoch consists of a number of slots, where each slot lasts for one second
  // A Cardano epoch currently includes 432,000 slots (5 days)
  // Format with miliseconds
  // mainnet: 432_000_000
  // preview: 1_800_000
  epoch_length: Int,
  // base is 5 days = 432_000_000
  epoch_length_base: Int,
}

pub type BondConfig {
  escrow_payment_key: ByteArray,
  escrow_policy_id: ByteArray,
  // basis_points reference value, default: 10_000
  basis_points_ref_unit: Int,
  // range basis_points min = 1, max = 9_999
  basis_points_min: Int,
  basis_points_max: Int,
  one_ada_2_lovelace: Int,
  // 1 bond = 100 ADA = 100_000_000 lovelace. default: 100 ADA = 100_000_000 lovelace
  bond_face_value: Int,
  epoch_config: EpochConfig,
}

pub type ExchangeConfigLimit {
  address: Address,
  // value in range 0001 -> 9999 default: 1% per yield == 100
  buyer_fee: Int,
  // value in range 0001 -> 9999 default: 1% per yield == 100
  seller_fee: Int,
  // Khoảng thời gian giao dịch sell hợp lệ, giá trị tính theo slot
  tx_buy_valid_slot: Option<Int>,
}

pub type ExchangeConfigMaking {
  address: Address,
  // value in range 0001 -> 9999 default: 1% per yield == 100
  maker_fee: Int,
  // value in range 0001 -> 9999 default: 1% per yield == 100
  taker_fee: Int,
  // Time frame for valid transaction, value represent slot
  tx_buy_valid_slot: Option<Int>,
}

pub type ConfigLimit {
  bond: BondConfig,
  exchange: ExchangeConfigLimit,
  slot_config_network: SlotConfigNetwork,
}

pub type ConfigMaking {
  bond: BondConfig,
  exchange: ExchangeConfigMaking,
  slot_config_network: SlotConfigNetwork,
}

pub type EscrowDatum {
  // PValue 'Sorted 'NoGuarantees: monthly lovelace value gain promised
  epo_rewards: Value,
  // PEpochTime: duration of the loan in epochs
  duration: Int,
  // PCurrencySymbol
  bond_symbol: ByteArray,
  // PTokenName: token name of both Uniqueness and Ownership NFTs
  token_name: ByteArray,
  // PInteger
  bond_amount: Int,
  // PEpochTime: number of epochs paid in advance
  buffer: Int,
  // PBasisPoints: Optim fee
  otm_fee: Int,
  // PPubKeyHash: used in staking the funds back to them
  og_lender: ByteArray,
  // PEpochTime
  start: Int,
}

pub type BondWriterDatum {
  epo_rewards: Value,
  duration: Int,
  bond_symbol: ByteArray,
  token_name: ByteArray,
  bond_amount: Int,
  buffer: Int,
  otmFee: Int,
  stake_key: StakeCredential,
  permissioned: Option<List<ByteArray>>,
}

pub type EscrowInfoResult<a, b> {
  OK(a)
  Error(b)
}

pub type EscrowInfo {
  bond_symbol: ByteArray,
  token_name: ByteArray,
  bond_amount: Int,
  start_epoch: Int,
  end_epoch: Int,
  received_at_maturity_one_bond: Int,
  day_to_maturity: Int,
}

pub type BizOutputInfo {
  addresses: List<Address>,
  bond_datum_valid: Bool,
  bond_outputs: List<Output>,
  bond_assets: Dict<AssetName, Int>,
  bond_qty: Int,
  lovelace: Int,
  other_outputs: List<Output>,
}

pub type BizOutput {
  valid: Bool,
  unique_bonds: Dict<AssetName, Int>,
  sc: BizOutputInfo,
  owner: BizOutputInfo,
  exchange: BizOutputInfo,
  other: BizOutputInfo,
}

pub type BizTxInfo {
  valid: Bool,
  biz_tx_in: BizOutput,
  biz_tx_out: Option<BizOutput>,
}

pub type DatumType {
  DatumTypePayment
  DatumTypeAskLimit
  DatumTypeBidLimit
  DatumTypeAskMaking
  DatumTypeBidMaking
}

pub type PaymentDatum {
  output_reference: OutputReference,
}

pub type AskLimit {
  owner_payment_key: ByteArray,
  owner_stake_key: Option<ByteArray>,
  requested_yield: Int,
}

pub type BidLimit {
  owner_payment_key: ByteArray,
  owner_stake_key: Option<ByteArray>,
  from_epoch: Int,
  to_epoch: Int,
  quantity: Int,
  requested_yield: Int,
}

pub type AskMaking {
  owner_payment_key: ByteArray,
  owner_stake_key: Option<ByteArray>,
  requested_yield: Int,
  bid_sc: ByteArray,
  margin: Int,
}

pub type BidMaking {
  owner_payment_key: ByteArray,
  owner_stake_key: Option<ByteArray>,
  from_epoch: Int,
  to_epoch: Int,
  quantity: Int,
  requested_yield: Int,
  ask_sc: ByteArray,
  margin: Int,
}

pub type OrderTypeDatum<a, b> {
  limit: a,
  making: b,
}

pub type OrderDatum<a, b> {
  ask: a,
  bid: b,
}

pub type DatumOf {
  OtherDatum
  ScDatum
  OwnerDatum
}

pub type TradeAction {
  Update
  Buy
  Sell
  Upgrade
}
