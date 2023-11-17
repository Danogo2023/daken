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
	convert_percent: Int,
}