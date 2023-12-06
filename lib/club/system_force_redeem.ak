use aiken/transaction.{Transaction}
use aiken/transaction/value.{PolicyId}
use club/danogo_feed/types.{ProtocolParams} as feed_type
use club/helpers.{
  get_trading_state_address, get_trading_state_ref_inputs,
  has_system_force_redeem,
}
use club/types.{DanogoClubConfig}

pub fn constraint(
  tx: Transaction,
  protocol_params: ProtocolParams,
  club_pid: PolicyId,
  cfg: DanogoClubConfig,
) -> Bool {
  let ts =
    get_trading_state_ref_inputs(
      club_pid,
      get_trading_state_address(protocol_params),
      tx.reference_inputs,
    )
  has_system_force_redeem(tx, cfg.epoch, cfg.slot, protocol_params, ts)
}
