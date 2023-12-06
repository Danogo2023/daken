use aiken/transaction/value.{PolicyId}

pub type WithdrawStateDatum {
  // owner of this utxo
  club_policy_id: PolicyId,
  // Total pool supply of withdraw pool token
  total_pool_supply: Int,
  // Increment Id
  pool_id: Int,
}

// gives base object, used for testing
pub fn base_withdraw_state_datum() -> WithdrawStateDatum {
  WithdrawStateDatum { club_policy_id: "", total_pool_supply: 0, pool_id: 0 }
}
