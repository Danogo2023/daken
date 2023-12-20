use aiken/math/rational.{Rational}
use aiken/transaction/value.{PolicyId}

pub type DepositPoolDatum {
  // dùng để giới hạn theo các thao tác spending theo club
  club_policy_id: PolicyId,
  epoch: Int,
  is_operator: Bool,
  pool_id: Int,
  // giá token đại diện 1 cổ phần của quỹ tại lần tính NAV gần nhất. share_token_price < 0 thì là chưa tính tính NAV lần nào
  share_token_price: Int,
  // Tỉ lệ chuyển đổi cho deposit, Operator luôn là 100% còn Member phụ thuộc vào tỉ lệ góp của Operator. convert_percent < 0 thì là chưa tính tính NAV lần nào
  convert_percent: Rational,
}

// gives base object, used for testing
pub fn base_deposit_pool_datum() -> DepositPoolDatum {
  DepositPoolDatum {
    club_policy_id: "",
    epoch: 440,
    is_operator: False,
    pool_id: 0,
    share_token_price: 0,
    convert_percent: rational.from_int(-1),
  }
}
