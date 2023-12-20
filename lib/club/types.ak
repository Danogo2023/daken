use aiken/transaction/value.{PolicyId}
use common/time.{EpochConfig, SlotConfig}

pub type DanogoClubConfig {
  // governance policy
  gov_pid: PolicyId,
  // data feed policy
  feed_pid: PolicyId,
  // time configs
  slot: SlotConfig,
  epoch: EpochConfig,
}
