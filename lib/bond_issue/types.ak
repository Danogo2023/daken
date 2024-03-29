use aiken/transaction/credential.{Address}
use aiken/transaction/value.{AssetName, PolicyId}
use common/pvalue.{PValue}
use common/time.{BasisPoints, EpochConfig, SlotConfig}

pub type RequestDatum {
  apr: Int,
  duration: Int,
  symbol: PolicyId,
  borrower: AssetName,
  requested: Int,
  issued: Int,
  epo_rewards: Int,
  prepaid: Int,
  buffer: Int,
  fee: Int,
}

pub type BondDatum {
  epo_rewards: PValue,
  duration: Int,
  bond_symbol: PolicyId,
  token_name: AssetName,
  bond_amount: Int,
  buffer: Int,
  fee: Int,
  borrower: AssetName,
  start: Int,
}

pub type BondIssueConfig {
  slot: SlotConfig,
  epoch: EpochConfig,
  basis: BasisPoints,
  platform: PlatformConfig,
}

pub type PlatformConfig {
  // 1 bond = 100 ADA = 100_000_000 lovelace. default: 100 ADA = 100_000_000 lovelace
  bond_face_value: Int,
  // value in range 0001 -> 9999 default: 500 (5%) per apr 
  fee: Int,
  // fee receive address
  fee_addr: Address,
  // Khoảng thời gian giao dịch hợp lệ, giá trị tính theo slot
  tx_ttl: Int,
  // default: 6 epoch
  min_buffer: Int,
  // datum.prepaid = Min(<min_buffer>+prepaid_plus, <duration>)
  prepaid_plus: Int,
  // default: 100 Bond = 10_000 ADA
  min_requested: Int,
  // default: 200 (2.00%)
  min_apr: Int,
  // default: 6 epoch
  min_duration: Int,
  // ada deposit addtionally to create borrow request, would be back to borrower when cancel
  min_ada: Int,
}
