use daken/time.{EpochConfig}

pub fn get_epoch_config_mainnet() -> EpochConfig {
  EpochConfig {
    year_to_epoch: 73,
    epoch_boundary: 1647899091000,
    epoch_boundary_as_epoch: 328,
    epoch_length: 432000000,
    epoch_length_base: 432000000,
  }
}

pub fn get_epoch_config_preview() -> EpochConfig {
  EpochConfig {
    year_to_epoch: 73,
    epoch_boundary: 1647899091000,
    epoch_boundary_as_epoch: 328,
    epoch_length: 1800000,
    epoch_length_base: 432000000,
  }
}
