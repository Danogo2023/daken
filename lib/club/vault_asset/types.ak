use aiken/transaction/value.{PolicyId}

pub type VaultAssetDatum {
  // dùng để giới hạn theo các thao tác spending theo club
  club_policy_id: PolicyId,
}
