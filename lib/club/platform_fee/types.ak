use aiken/transaction/value.{PolicyId}

pub type PlatformFeeDatum {
  // dùng để xác định utxo chứa phí mà platform thu của club nào
  club_policy_id: PolicyId,
}
