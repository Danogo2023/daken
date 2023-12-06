use aiken/builtin
use aiken/bytearray

/// convert a number into its bytearray's representative
/// e.g: 0xABCD1, 5 -> #"00 00 0A BC D1"
/// if no. of bytes is not suffice, get the least significant value
pub fn number_to_bytearray_hex(number: Int, bytes: Int) -> ByteArray {
  do_convert_reversed(number, bytes) // flip string back to normal (big endian)
    |> bytearray.foldl("", fn(b, ret) { builtin.cons_bytearray(b, ret) })
}

/// convert number into reversed string (little endian)
/// e.g: 0xABCD1, 5 -> #"D1 BC 0A 00 00"
fn do_convert_reversed(currnum: Int, currbytes: Int) -> ByteArray {
  when currbytes is {
    0 -> #""
    _ ->
      builtin.cons_bytearray(
        currnum % 0x100,
        do_convert_reversed(currnum / 0x100, currbytes - 1),
      )
  }
}

test convert_num_to_hex_1() {
  number_to_bytearray_hex(0xabcd1, 5) == #"00000abcd1"
}

test convert_num_to_hex_2() {
  number_to_bytearray_hex(0, 3) == #"000000"
}

test convert_num_to_hex_3() {
  number_to_bytearray_hex(0, 0) == #""
}

test convert_num_to_hex_4() {
  number_to_bytearray_hex(0xabcd1, 2) == #"bcd1"
}
