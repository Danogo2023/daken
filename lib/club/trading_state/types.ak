use aiken/transaction/value.{PolicyId}

pub type TradingStateDatum {
  // owner of this utxo
  club_policy_id: PolicyId,
  // protocol ids this club is allowed to interact
  protocols: List<Int>,
  // ================== force status ===================
  // status force divest only, can be toggled by any users when conditions meet
  force_liquidation: Bool,
  // status force close club, used by OP NFT
  force_closed: Bool,
  // epoch toggle force closed on
  force_closed_at_epoch: Int,
  // ================== vault ===================
  // Số lượng vault của club sẽ tương ứng với số lượng stake key club đang sử dụng (update khi tách vault để Staking ở Pool mới và chỉ duy nhất lần tính NAV đầu tiền khi chưa có vault nào thì tằng giá trị từ 0 lên 1)
  // update when splitting vault for staking
  // default 0, first nav -> 1
  total_vault_supply: Int,
  // increment id
  vault_id: Int,
  // index of stake keys this club has delegated
  delegated_idx_stake_keys: List<Int>,
  // last time this club withdraw rewards from staking
  last_rewards_withdrawal_at_epoch: Int,
}

// gives base object, used for testing
pub fn base_trading_state_datum() -> TradingStateDatum {
  TradingStateDatum {
    club_policy_id: "",
    protocols: [],
    force_liquidation: False,
    force_closed: False,
    force_closed_at_epoch: 440,
    total_vault_supply: 0,
    vault_id: 0,
    delegated_idx_stake_keys: [],
    last_rewards_withdrawal_at_epoch: 0,
  }
}
