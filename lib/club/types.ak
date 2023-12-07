use aiken/transaction/value.{PolicyId}
use common/time.{EpochConfig, SlotConfig}

pub type DanogoClubConfig {
  gov_pid: PolicyId,
  slot: SlotConfig,
  epoch: EpochConfig,
}
