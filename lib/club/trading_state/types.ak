use aiken/transaction/value.{PolicyId}

pub type TradingStateDatum {
  // owner of this utxo
  club_policy_id: PolicyId,
  // protocol ids this club is allowed to interact
  protocols: List<Int>,
  // status force divest only, can be toggled by any users when conditions meet
  force_liquidation: Bool,
  // status force close club, used by OP NFT
  force_closed: Bool,
  // epoch toggle force closed on
  force_closed_at_epoch: Int,
}

// gives base object, used for testing
pub fn base_trading_state_datum() -> TradingStateDatum {
  TradingStateDatum {
    club_policy_id: "",
    protocols: [],
    force_liquidation: False,
    force_closed: False,
    force_closed_at_epoch: 440,
  }
}
