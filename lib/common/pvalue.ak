use aiken/dict
use aiken/list
use aiken/transaction/value.{
  AssetName, PolicyId, Value, ada_asset_name, ada_policy_id,
}

pub type PValue =
  List<(PolicyId, List<(AssetName, Int)>)>

pub fn to_value(self: PValue) {
  list.foldl(
    self,
    value.zero(),
    fn(pid_to_assets, val) {
      let (pid, assets) = pid_to_assets
      list.foldl(
        assets,
        val,
        fn(ast, val) {
          let (name, qty) = ast
          value.add(val, pid, name, qty)
        },
      )
    },
  )
}

pub fn from_value(val: Value) -> PValue {
  value.to_dict(val)
    |> dict.to_list
    |> list.foldr(
         [],
         fn(pid_to_assets, pval) {
           let (pid, assets) = pid_to_assets
           [(pid, dict.to_list(assets)), ..pval]
         },
       )
}

// test match_snapshot() {
//   cbor.serialise([("pid", [("name", 1)])]) == cbor.serialise(
//     value.from_asset("pid", "name", 1),
//   )
// }

test to_value_1_lovelace() {
  to_value([(ada_policy_id, [(ada_asset_name, 1)])]) == value.from_lovelace(1)
}

test to_value_0_lovelace() {
  to_value([(ada_policy_id, [(ada_asset_name, 0)])]) == value.zero()
}

test to_value_1_asset() {
  to_value([("pid", [("name", 1)])]) == value.from_asset("pid", "name", 1)
}

test to_value_1_asset_negate() {
  to_value([("pid", [("name", -1)])]) == value.from_asset("pid", "name", -1)
}

test to_value_2_assets_same_policy() {
  to_value([("pid", [("name", 1), ("name_2", 1)])]) == (
    value.from_asset("pid", "name", 1)
      |> value.add("pid", "name_2", 1)
  )
}

test to_value_2_assets_different_policies() {
  to_value([("pid", [("name", 1)]), ("pid_2", [("name", 1)])]) == (
    value.from_asset("pid", "name", 1)
      |> value.add("pid_2", "name", 1)
  )
}

test from_value_1_lovelace() {
  from_value(value.from_lovelace(1)) == [(ada_policy_id, [(ada_asset_name, 1)])]
}

test from_value_0_lovelace() {
  from_value(value.from_lovelace(0)) == []
}

test from_value_1_asset() {
  from_value(value.from_asset("pid", "name", 1)) == [("pid", [("name", 1)])]
}

test from_value_1_asset_negate() {
  to_value([("pid", [("name", -1)])]) == value.from_asset("pid", "name", -1)
}

test from_value_2_assets_same_policy() {
  from_value(
    value.from_asset("pid", "name", 1)
      |> value.add("pid", "name_2", 1),
  ) == [("pid", [("name", 1), ("name_2", 1)])]
}

test from_value_2_assets_different_policies() {
  from_value(
    value.from_asset("pid", "name", 1)
      |> value.add("pid_2", "name", 1),
  ) == [("pid", [("name", 1)]), ("pid_2", [("name", 1)])]
}
