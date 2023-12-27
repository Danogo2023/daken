use aiken/transaction/value.{PolicyId}

pub type DepositStateDatum {
  // dùng để giới hạn theo các thao tác spending theo club
  club_policy_id: PolicyId,
  // Tổng cung lưu hành của Deposit Pool Token 
  total_pool_supply: Int,
  // Increment Id
  pool_id: Int,
  // control number of pools created in current epoch, default 0
  latest_pool_epoch: Int,
  latest_pool_num: Int,
}

// gives base object, used for testing
pub fn base_deposit_state_datum() -> DepositStateDatum {
  DepositStateDatum {
    club_policy_id: "",
    total_pool_supply: 0,
    pool_id: 0,
    latest_pool_epoch: 0,
    latest_pool_num: 0,
  }
}
