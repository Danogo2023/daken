use aiken/cbor
use aiken/math/rational.{Rational}

pub type PRational {
  numerator: Int,
  denominator: Int,
}

pub fn from_rational(num: Rational) -> PRational {
  PRational {
    numerator: rational.numerator(num),
    denominator: rational.denominator(num),
  }
}

pub fn to_rational(num: PRational) -> Rational {
  expect Some(rnum) = rational.new(num.numerator, num.denominator)
  rnum
}

test get_prational() {
  expect Some(rnum) = rational.new(1, 2)
  from_rational(rnum) == PRational { numerator: 1, denominator: 2 }
}

test match_snapshot() {
  let pra = PRational { numerator: 99, denominator: 88 }
  // expect Some(ra) = rational.new(99, 88)
  // trace cbor.diagnostic(cbor.serialise(ra))
  (cbor.serialise(pra) == #"d8799f18631858ff")?
}
