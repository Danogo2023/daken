use aiken/interval.{
  Finite, Interval, IntervalBound, PositiveInfinity, entirely_between,
}
use aiken/time.{PosixTime}
use aiken/transaction.{ValidityRange}

pub type BasisPoints {
  // basis_points reference value, default: 10_000
  base: Int,
  // range basis_points min = 1, max = 9_999
  min: Int,
  max: Int,
}

pub type SlotConfig {
  zero_time: PosixTime,
  zero_slot: Int,
  slot_length: Int,
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

pub fn get_slot_config_network_preview() -> SlotConfig {
  SlotConfig { zero_time: 1666656000000, zero_slot: 0, slot_length: 1000 }
}

pub fn get_slot_config_network_mainnet() -> SlotConfig {
  SlotConfig { zero_time: 1596059091000, zero_slot: 4492800, slot_length: 1000 }
}

pub type EpochConfig {
  // 1 year = 365 days / 5 days per epoch = 73 epoch. default: 73
  year_to_epoch: Int,
  // default: 1_647_899_091_000
  epoch_boundary: Int,
  // default: epoch 327+1
  epoch_boundary_as_epoch: Int,
  // Each Cardano epoch consists of a number of slots, where each slot lasts for one second
  // A Cardano epoch currently includes 432,000 slots (5 days)
  // Format with miliseconds
  // mainnet: 432_000_000
  // preview: 1_800_000
  epoch_length: Int,
  // base is 5 days = 432_000_000
  epoch_length_base: Int,
}

pub fn slot_to_begin_posix_time(slot: Int, slot_config: SlotConfig) -> PosixTime {
  slot_config.zero_time + ( slot - slot_config.zero_slot ) * slot_config.slot_length
}

pub fn posix_time_to_enclosing_slot(
  posix_time: PosixTime,
  slot_config: SlotConfig,
) -> Int {
  ( posix_time - slot_config.zero_time ) / slot_config.slot_length + slot_config.zero_slot
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

pub fn posix_time_to_relative_epoch(
  posix_time: Int,
  epoch_config: EpochConfig,
) -> Int {
  ( posix_time - epoch_config.epoch_boundary ) / epoch_config.epoch_length + epoch_config.epoch_boundary_as_epoch
}

pub fn get_current_epoch(range: ValidityRange, e: EpochConfig) -> Int {
  when range.upper_bound.bound_type is {
    Finite(_) ->
      when range.lower_bound.bound_type is {
        Finite(x) -> posix_time_to_relative_epoch(x, e)
        _ -> fail @"tx_time not set"
      }
    _ -> fail @"tx_ttl not set"
  }
}

pub fn get_current_epoch_with_ttl(
  v: ValidityRange,
  e: EpochConfig,
  ttl: Int,
  slot_length: Int,
) -> Int {
  posix_time_to_relative_epoch(tx_validity_valid(v, slot_length, Some(ttl)), e)
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
  slot_length: Int,
  ttl: Option<Int>,
) -> Int {
  let tx_start =
    when v.lower_bound.bound_type is {
      Finite(x) -> x
      _ -> 0
    }
  let tx_end =
    when v.upper_bound.bound_type is {
      Finite(x) -> x
      _ -> 0
    }
  let expire =
    when ttl is {
      Some(x) -> x
      None -> 3 * 60
    } * slot_length
  if and {
    (tx_start > 0)?,
    (tx_end > 0)?,
    (tx_end >= tx_start)?,
    (tx_end - tx_start <= expire)?,
  } {
    tx_start
  } else {
    fail @"tx validity_range invalid"
  }
}
