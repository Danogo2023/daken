use aiken/transaction/value.{PolicyId}

pub type NavStateDatum {
  // dùng để giới hạn theo các thao tác spending theo club
  club_policy_id: PolicyId,
  // epoch tính NAV gần nhất
  calc_epoch_latest: Int,
  // giá token đại diện 1 cổ phần của quỹ tại lần tính NAV gần nhất. share_token_price < 0 thì là chưa tính tính NAV lần nào
  share_token_price: Int,
  // Tổng cung lưu hành của Member Token
  total_member_supply: Int,
  // Tổng cung lưu hành của OP Token 
  total_operator_supply: Int,
  // số tiền phí quản lý thu trong lần tính NAV
  management_fee: Int,
  // số tiền thưởng hiệu suất hoạt động thu trong lần tính NAV
  performance_fee: Int,
  // số tiền Danogo Club thu trong lần tính NAV
  platform_fee: Int,
  // Số lượng vault của club sẽ tương ứng với số lượng stake key club đang sử dụng (update khi tách vault để Staking ở Pool mới và chỉ duy nhất lần tính NAV đầu tiền khi chưa có vault nào thì tằng giá trị từ 0 lên 1)
  vault_num: Int,
}

// gives base object, used for testing
pub fn base_nav_state_datum() -> NavStateDatum {
  NavStateDatum {
    club_policy_id: "",
    calc_epoch_latest: 0,
    share_token_price: -1,
    total_member_supply: 0,
    total_operator_supply: 0,
    management_fee: 0,
    performance_fee: 0,
    platform_fee: 0,
    vault_num: 0,
  }
}
