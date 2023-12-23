use aiken/bytearray
use aiken/cbor
use aiken/string
use aiken/transaction/value.{AssetName, PolicyId}

pub fn compare(left: String, right: String) -> Ordering {
  bytearray.compare(string.to_bytearray(left), string.to_bytearray(right))
}

pub fn to_unit_1(pid: PolicyId, sep: String, a: AssetName) -> String {
  bconcat_2(pid, sep, a)
}

test to_unit_1_test() {
  let p = #"5f1dd3192cbdaa2c1a91560a6147466efb18d33a5d6516b266ce6b6f"
  let n = #"f64c5f8eba3b5a60aff7b4068d0f321f5560db242e56345b8bd04017ebe47bef"
  let r = to_unit_1(p, @".", n)
  trace r
  r == @"5f1dd3192cbdaa2c1a91560a6147466efb18d33a5d6516b266ce6b6f.f64c5f8eba3b5a60aff7b4068d0f321f5560db242e56345b8bd04017ebe47bef"
}

pub fn to_unit_2(pid: PolicyId, sep: String, a: AssetName) -> ByteArray {
  pid |> bytearray.concat(bytearray.from_string(sep)) |> bytearray.concat(a)
}

test to_unit_2_test() {
  let p = #"5f1dd3192cbdaa2c1a91560a6147466efb18d33a5d6516b266ce6b6f"
  let n = #"f64c5f8eba3b5a60aff7b4068d0f321f5560db242e56345b8bd04017ebe47bef"
  let r = bytearray.to_hex(to_unit_2(p, @".", n))
  trace r
  r == @"5f1dd3192cbdaa2c1a91560a6147466efb18d33a5d6516b266ce6b6f2ef64c5f8eba3b5a60aff7b4068d0f321f5560db242e56345b8bd04017ebe47bef"
}

pub fn to_unit_3(pid: PolicyId, sep: String, a: AssetName) -> String {
  bytearray.to_hex(pid)
    |> string.concat(sep)
    |> string.concat(bytearray.to_hex(a))
}

test to_unit_3_test_1() {
  let p = #"5f1dd3192cbdaa2c1a91560a6147466efb18d33a5d6516b266ce6b6f"
  let n = #"f64c5f8eba3b5a60aff7b4068d0f321f5560db242e56345b8bd04017ebe47bef"
  let r = to_unit_3(p, @".", n)
  trace r
  r == @"5f1dd3192cbdaa2c1a91560a6147466efb18d33a5d6516b266ce6b6f.f64c5f8eba3b5a60aff7b4068d0f321f5560db242e56345b8bd04017ebe47bef"
}

test to_unit_3_test_2() {
  let p = #"5f1dd3192cbdaa2c1a91560a6147466efb18d33a5d6516b266ce6b6f"
  let n = #"f64c5f8eba3b5a60aff7b4068d0f321f5560db242e56345b8bd04017ebe47bef"
  let r = bytearray.from_string(to_unit_3(p, @".", n))
  trace cbor.diagnostic(r)
  trace bytearray.to_string(r)
  bytearray.to_string(r) == @"5f1dd3192cbdaa2c1a91560a6147466efb18d33a5d6516b266ce6b6f.f64c5f8eba3b5a60aff7b4068d0f321f5560db242e56345b8bd04017ebe47bef"
}

pub fn print_compare(
  prefix: String,
  left: ByteArray,
  op: String,
  right: ByteArray,
) -> String {
  prefix
    |> string.concat(bytearray.to_hex(left))
    |> string.concat(op)
    |> string.concat(bytearray.to_hex(right))
}

pub fn bconcat_prefix(left: ByteArray, right: String) -> String {
  bytearray.to_hex(left) |> string.concat(right)
}

pub fn bconcat_subfix(left: String, right: ByteArray) -> String {
  left |> string.concat(bytearray.to_hex(right))
}

pub fn bconcat_1(left: String, center: ByteArray, right: String) -> String {
  left |> string.concat(bytearray.to_hex(center)) |> string.concat(right)
}

pub fn bconcat_2(left: ByteArray, center: String, right: ByteArray) -> String {
  bytearray.to_hex(left)
    |> string.concat(center)
    |> string.concat(bytearray.to_hex(right))
}

pub fn bconcat_3(left: String, center: String, right: String) -> String {
  left |> string.concat(center) |> string.concat(right)
}

pub fn bconcat_4(left: ByteArray, center: ByteArray, right: ByteArray) -> String {
  bytearray.to_hex(left)
    |> string.concat(bytearray.to_hex(center))
    |> string.concat(bytearray.to_hex(right))
}
