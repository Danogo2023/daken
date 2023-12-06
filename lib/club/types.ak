use aiken/transaction/value.{PolicyId}
use common/time.{EpochConfig, SlotConfigNetwork}

pub type DanogoClubConfig {
  gov_pid: PolicyId,
  slot: SlotConfigNetwork,
  epoch: EpochConfig,
}
