use aiken/transaction/value.{PolicyId}

pub type DepositStateDatum {
	// dùng để giới hạn theo các thao tác spending theo club
	club_policy_id: PolicyId,
	// Tổng cung lưu hành của Deposit Pool Token 
	total_pool_supply: Int,
	// Increment Id
	pool_id: Int,
}
