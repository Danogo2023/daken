use aiken/interval.{Finite, Interval, IntervalBound, PositiveInfinity}
use aiken/time.{PosixTime}
use aiken/transaction.{ValidityRange}

pub type SlotConfigNetwork {
  zero_time: PosixTime,
  zero_slot: Int,
  slot_length: Int,
}

pub fn slot_to_begin_posix_time(
  slot: Int,
  slot_config: SlotConfigNetwork,
) -> PosixTime {
  slot_config.zero_time + ( slot - slot_config.zero_slot ) * slot_config.slot_length
}

pub fn posix_time_to_enclosing_slot(
  posix_time: PosixTime,
  slot_config: SlotConfigNetwork,
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
