use aiken/math

pub type BitSet =
  Int

pub fn has(self: BitSet, idx: Int) -> Bool {
  expect idx >= 0
  expect self >= 0

  let mask = math.pow2(idx)
  let upper_mask = 2 * mask
  self % upper_mask >= mask
}

pub fn add(self: BitSet, idx: Int) -> BitSet {
  expect idx >= 0
  expect self >= 0

  if has(self, idx) {
    self
  } else {
    let mask = math.pow2(idx)
    self + mask
  }
}

pub fn must_add(self: BitSet, idx: Int) -> BitSet {
  expect !has(self, idx)
  let mask = math.pow2(idx)
  self + mask
}

test has_1() {
  and {
    !has(0, 0),
    has(1, 0),
    !has(1, 1),
    has(7, 0),
    has(7, 1),
    has(7, 2),
    !has(7, 3),
    !has(12, 0),
    !has(12, 1),
    has(12, 2),
    has(12, 3),
    !has(12, 4),
    has(math.pow2(97), 97),
  }
}

test has_2() fail {
  has(1, -1)
}

test has_3() fail {
  has(-1, 0)
}

test add_1() fail {
  add(0, -1) != -1
}

test add_2() fail {
  add(-1, 0) != -1
}

test add_3() {
  and {
    add(0, 0) == 1,
    add(0, 1) == 2,
    add(2, 1) == 2,
    add(2, 0) == 3,
    add(0, 3) == 8,
    add(0, 97) == math.pow2(97),
    add(6, 0) == 7,
    add(5, 1) == 7,
  }
}

test must_add_1() fail {
  must_add(1, 0) != -1
}

test must_add_2() fail {
  must_add(-1, 0) != -1
}

test must_add_3() fail {
  must_add(0, -1) != -1
}

test must_add_4() {
  and {
    must_add(0, 0) == 1,
    must_add(0, 1) == 2,
    must_add(1, 1) == 3,
    must_add(6, 0) == 7,
    must_add(5, 1) == 7,
    must_add(0, 63) == math.pow2(63),
  }
}
