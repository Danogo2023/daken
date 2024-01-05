use aiken/transaction/value.{PolicyId}

pub type WithdrawPoolDatum {
  // dùng để giới hạn theo các thao tác spending theo club
  club_policy_id: PolicyId,
  epoch: Int,
  pool_id: Int,
  // giá token đại diện 1 cổ phần của quỹ tại lần tính NAV gần nhất. share_token_price < 0 là giá không hợp lệ để sử dụng
  share_token_price: Int,
  // epoch calculated nav, default -1
  calc_nav_at_epoch: Int,
  // copy from trading state when calc nav, default -1
  early_withdraw_penalty: Int,
  hurdle_rate: Int,
  performance_bonus_rate: Int,
  lockup_period: Int,
}

// gives base object, used for testing
pub fn base_withdraw_pool_datum() -> WithdrawPoolDatum {
  WithdrawPoolDatum {
    club_policy_id: "",
    epoch: 0,
    pool_id: 0,
    share_token_price: -1,
    calc_nav_at_epoch: -1,
    early_withdraw_penalty: -1,
    hurdle_rate: -1,
    performance_bonus_rate: -1,
    lockup_period: -1,
  }
}
