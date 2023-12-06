use aiken/transaction/value.{Value}

pub type Lovelace =
  Int

/// check both value have same assets, excluding lovelace
pub fn same_assets(v1: Value, v2: Value) -> Bool {
  let negated =
    v1
      |> value.without_lovelace()
      |> value.negate()
      |> value.merge(value.without_lovelace(v2))
  negated == value.zero()
}

test correct_same_assets_1() {
  let v1 =
    value.from_asset("policy1", "token1", 20)
      |> value.add("policy2", "token2", 5) // add lovelace
      |> value.add("", "", 400)
  let v2 =
    value.from_asset("policy2", "token2", 5)
      |> value.add("policy1", "token1", 20) // add lovelace
      |> value.add("", "", 1000)
  same_assets(v1, v2)
}

test correct_same_assets_2() {
  let v1 =
    value.from_asset("policy1", "token1", 20)
      |> value.add("policy2", "token2", 5)
      |> value.add("policy1", "token3", 1)
  let v2 =
    value.from_asset("policy2", "token2", 5)
      |> value.add("policy1", "token1", 20)
  !same_assets(v1, v2)
}

test correct_same_assets_3() {
  let v1 = value.from_asset("policy1", "token1", 20)
  let v2 =
    value.from_asset("policy2", "token2", 5)
      |> value.add("policy1", "token1", 20)
  !same_assets(v1, v2)
}
