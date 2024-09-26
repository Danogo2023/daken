use aiken/interval.{
  Finite, Interval, IntervalBound, PositiveInfinity, entirely_between,
}
use cardano/transaction.{ValidityRange}
use daken/types.{Basis, Error, OK, PosixTime, Result}

pub type BasisPoints {
  // basis_points reference value, default: 10_000
  base: Basis,
  // range basis_points min = 1, max = 9_999
  min: Basis,
  max: Basis,
}

pub fn get_basis_points_config() -> BasisPoints {
  BasisPoints { base: 10000, min: 1, max: 9999 }
}

pub type DayNum =
  Int

pub type Milliseconds =
  Int

pub type Seconds =
  Int

pub type EpochTime =
  Int

pub type SlotTime =
  Int

pub type SlotConfig {
  zero_time: PosixTime,
  zero_slot: SlotTime,
  slot_length: Milliseconds,
}

pub fn get_slot_config_network_preview() -> SlotConfig {
  SlotConfig { zero_time: 1666656000000, zero_slot: 0, slot_length: 1000 }
}

pub fn get_slot_config_network_mainnet() -> SlotConfig {
  SlotConfig { zero_time: 1596059091000, zero_slot: 4492800, slot_length: 1000 }
}

pub type EpochConfig {
  // 1 year = 365 days / 5 days per epoch = 73 epoch. default: 73
  year_to_epoch: EpochTime,
  // default: 1_647_899_091_000
  epoch_boundary: PosixTime,
  // default: epoch 327+1
  epoch_boundary_as_epoch: EpochTime,
  // Each Cardano epoch consists of a number of slots, where each slot lasts for one second
  // A Cardano epoch currently includes 432,000 slots (5 days)
  // Format with miliseconds
  // mainnet: 432_000_000
  // preview: 1_800_000
  epoch_length: Milliseconds,
  // base is 5 days = 432_000_000
  epoch_length_base: Milliseconds,
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

pub fn get_epoch_config_mainnet() -> EpochConfig {
  EpochConfig {
    year_to_epoch: 73,
    epoch_boundary: 1647899091000,
    epoch_boundary_as_epoch: 328,
    epoch_length: 432000000,
    epoch_length_base: 432000000,
  }
}

pub fn slot_to_begin_posix_time(t: SlotTime, cfg: SlotConfig) -> PosixTime {
  cfg.zero_time + ( t - cfg.zero_slot ) * cfg.slot_length
}

pub fn posix_time_to_enclosing_slot(t: PosixTime, cfg: SlotConfig) -> SlotTime {
  ( t - cfg.zero_time ) / cfg.slot_length + cfg.zero_slot
}

pub fn must_start_after(range: ValidityRange, lower_bound: PosixTime) -> Bool {
  when range.lower_bound.bound_type is {
    Finite(now) -> now > lower_bound
    _ -> False
  }
}

test must_start_after_1() {
  let now: Int = 2

  let validity_range =
    Interval {
      lower_bound: IntervalBound(Finite(now), True),
      upper_bound: IntervalBound(PositiveInfinity, True),
    }

  let lower_bound = 1
  must_start_after(validity_range, lower_bound)
}

test must_start_after_2() {
  let now: Int = 1

  let validity_range =
    Interval {
      lower_bound: IntervalBound(Finite(now), True),
      upper_bound: IntervalBound(PositiveInfinity, True),
    }

  let lower_bound = 2
  must_start_after(validity_range, lower_bound) == False
}

pub fn must_start_before(range: ValidityRange, lower_bound: PosixTime) -> Bool {
  when range.lower_bound.bound_type is {
    Finite(now) -> now < lower_bound
    _ -> False
  }
}

test must_start_before_1() {
  let now: Int = 1

  let validity_range =
    Interval {
      lower_bound: IntervalBound(Finite(now), True),
      upper_bound: IntervalBound(PositiveInfinity, True),
    }

  let lower_bound = 2
  must_start_before(validity_range, lower_bound)
}

test must_start_before_2() {
  let now: Int = 2

  let validity_range =
    Interval {
      lower_bound: IntervalBound(Finite(now), True),
      upper_bound: IntervalBound(PositiveInfinity, True),
    }

  let lower_bound = 1
  must_start_before(validity_range, lower_bound) == False
}

pub fn get_milliseconds_of_day(cfg: EpochConfig) -> Milliseconds {
  cfg.epoch_length * 86400000 / cfg.epoch_length_base
}

pub fn posix_time_to_relative_epoch(t: PosixTime, cfg: EpochConfig) -> EpochTime {
  ( t - cfg.epoch_boundary ) / cfg.epoch_length + cfg.epoch_boundary_as_epoch
}

pub fn relative_epoch_to_posix_time_start(
  epo: EpochTime,
  cfg: EpochConfig,
) -> PosixTime {
  ( epo - cfg.epoch_boundary_as_epoch ) * cfg.epoch_length + cfg.epoch_boundary
}

pub fn relative_epoch_to_posix_time_end(
  epo: EpochTime,
  cfg: EpochConfig,
) -> PosixTime {
  relative_epoch_to_posix_time_start(epo, cfg) + cfg.epoch_length
}

pub fn get_current_epoch(v: ValidityRange, cfg: EpochConfig) -> EpochTime {
  when v.upper_bound.bound_type is {
    Finite(_) ->
      when v.lower_bound.bound_type is {
        Finite(t) -> posix_time_to_relative_epoch(t, cfg)
        _ -> fail @"tx_time not set"
      }
    _ -> fail @"tx_ttl not set"
  }
}

pub fn get_current_epoch_with_ttl(
  v: ValidityRange,
  cfg: EpochConfig,
  ttl: Seconds,
  slot_length: Milliseconds,
) -> EpochTime {
  expect OK(tx_time) = tx_validity_valid(v, slot_length, Some(ttl), True)
  posix_time_to_relative_epoch(tx_time, cfg)
}

pub fn get_current_epoch_and_boundaries_with_ttl(
  v: ValidityRange,
  cfg: EpochConfig,
  ttl: Seconds,
  slot_length: Milliseconds,
) -> (EpochTime, PosixTime, PosixTime) {
  expect OK((start_time, end_time)) =
    tx_validity_valid_with_boundaries(v, slot_length, Some(ttl), True)
  (posix_time_to_relative_epoch(start_time, cfg), start_time, end_time)
}

test posix_time_to_relative_epoch_test1() {
  posix_time_to_relative_epoch(1700553368000, get_epoch_config_preview()) == 29580
}

test get_current_epoch_test1() {
  let validity_range = entirely_between(1700553368000, 1700553369000)
  get_current_epoch(validity_range, get_epoch_config_preview()) == 29580
}

pub fn tx_validity_valid(
  v: ValidityRange,
  slot_length: Milliseconds,
  ttl: Option<Seconds>,
  tx_end_must_set: Bool,
) -> Result<PosixTime, String> {
  when v.lower_bound.bound_type is {
    Finite(tx_start) -> {
      let expire =
        when ttl is {
          Some(x) -> x
          None -> 3 * 60
        } * slot_length
      let tx_end =
        when v.upper_bound.bound_type is {
          Finite(x) -> x
          _ ->
            if tx_end_must_set {
              0
            } else {
              tx_start + expire
            }
        }
      if and {
        (tx_start > 0)?,
        (tx_end >= tx_start)?,
        (tx_end - tx_start <= expire)?,
      } {
        OK(tx_start)
      } else {
        Error(@"tx time invalid")
      }
    }
    _ -> Error(@"tx time not set")
  }
}

pub fn tx_validity_valid_with_boundaries(
  v: ValidityRange,
  slot_length: Milliseconds,
  ttl: Option<Seconds>,
  tx_end_must_set: Bool,
) -> Result<(PosixTime, PosixTime), String> {
  when v.lower_bound.bound_type is {
    Finite(tx_start) -> {
      let expire =
        when ttl is {
          Some(x) -> x
          None -> 3 * 60
        } * slot_length
      let tx_end =
        when v.upper_bound.bound_type is {
          Finite(x) -> x
          _ ->
            if tx_end_must_set {
              0
            } else {
              tx_start + expire
            }
        }
      if and {
        (tx_start > 0)?,
        (tx_end >= tx_start)?,
        (tx_end - tx_start <= expire)?,
      } {
        OK((tx_start, tx_end))
      } else {
        Error(@"tx time invalid")
      }
    }
    _ -> Error(@"tx time not set")
  }
}
