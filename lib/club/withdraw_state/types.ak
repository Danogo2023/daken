use aiken/transaction/value.{PolicyId}

pub type WithdrawStateDatum {
  // owner of this utxo
  club_policy_id: PolicyId,
  // Total pool supply of withdraw pool token
  total_pool_supply: Int,
  // Increment Id
  pool_id: Int,
  // control number of pools created in current epoch, default 0
  latest_pool_epoch: Int,
  latest_pool_num: Int,
}

// gives base object, used for testing
pub fn base_withdraw_state_datum() -> WithdrawStateDatum {
  WithdrawStateDatum {
    club_policy_id: "",
    total_pool_supply: 0,
    pool_id: 0,
    latest_pool_epoch: 0,
    latest_pool_num: 0,
  }
}
