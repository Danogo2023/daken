use aiken/transaction/value.{AssetName, PolicyId, Value}

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
  epo_rewards: Value,
  duration: Int,
  bond_symbol: PolicyId,
  token_name: AssetName,
  bond_amount: Int,
  buffer: Int,
  fee: Int,
  borrower: AssetName,
  start: Int,
}
