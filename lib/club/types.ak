use aiken/transaction/value.{PolicyId}
use common/time.{EpochConfig, SlotConfig}
use common/types.{Lovelace}

pub type DanogoClubConfig {
  // governance policy
  gov_pid: PolicyId,
  // data feed policy
  feed_pid: PolicyId,
  // time configs
  slot: SlotConfig,
  epoch: EpochConfig,
  // fee (lovelace) deposit/receive when register/unregister a stake account
  stake_registration_fee: Lovelace,
}
