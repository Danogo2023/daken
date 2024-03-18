use aiken/transaction/value.{PolicyId}
use common/pvalue.{PValue}

pub type VaultStateDatum {
  // owner of this utxo
  club_policy_id: PolicyId,
  // protocol ids this club is allowed to interact
  is_default: Bool,
  // minADA of vault assets
  min_vault_asset_ada: Int,
  // last epoch invest/divest
  last_active_epoch: Int,
  // assets that is in club vault
  assets: PValue,
  // vault utxos
  count_utxo: Int,
  // id of vault
  vault_id: Int,
}

pub type VaultAssetDatum {
  // dùng để giới hạn theo các thao tác spending theo club
  club_policy_id: PolicyId,
}

// gives base object, used for testing
pub fn base_vault_state_datum() -> VaultStateDatum {
  VaultStateDatum {
    club_policy_id: "",
    is_default: True,
    min_vault_asset_ada: 0,
    last_active_epoch: 440,
    assets: pvalue.from_value(value.zero()),
    count_utxo: 0,
    vault_id: 0,
  }
}

pub fn base_vault_asset_datum(club_policy_id: ByteArray) -> VaultAssetDatum {
  VaultAssetDatum { club_policy_id }
}
