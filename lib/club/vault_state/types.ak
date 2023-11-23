use aiken/transaction/value.{PolicyId, Value}

pub type VaultStateDatum {
  // owner of this utxo
  club_policy_id: PolicyId,
  // protocol ids this club is allowed to interact
  is_default: Bool,
  // expendable ADA, minADA not included
  total_available_ada: Int,
  // last epoch invest/divest
  last_active_epoch: Int,
  // assets that is in club vault
  assets: Value,
  // vault utxos
  count_utxo: Int,
  // id of vault
  vault_id: Int,
}

// gives base object, used for testing
pub fn base_vault_state_datum() -> VaultStateDatum {
  VaultStateDatum {
    club_policy_id: "",
    is_default: True,
    total_available_ada: 0,
    last_active_epoch: 440,
    assets: value.zero(),
    count_utxo: 0,
    vault_id: 0,
  }
}
