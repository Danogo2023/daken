use aiken/transaction/value.{PolicyId}
use common/prational.{PRational}

pub type RedeemPoolDatum {
  // dùng để giới hạn theo các thao tác spending theo club
  club_policy_id: PolicyId,
  // giá token đại diện 1 cổ phần của quỹ tại lần tính NAV gần nhất. share_token_price < 0 là giá không hợp lệ để sử dụng
  share_token_price: PRational,
}
