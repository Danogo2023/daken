use aiken/collection/list
use aiken/crypto
use aiken/primitive/bytearray
use cardano/address
use cardano/assets
use cardano/transaction.{Input, NoDatum, Output, OutputReference}
use daken/convert
use daken/input_hash
use daken/sort
use daken/types.{Blake2b224Hash, Blake2b256Hash}

pub fn blake2b_256(inputs: List<Input>) -> Blake2b256Hash {
  inputs
    |> list.foldl(
        #"",
        fn(
          Input {
            output_reference: OutputReference { transaction_id, output_index },
            ..
          }: Input,
          ret: ByteArray,
        ) -> ByteArray {
          convert.int_to_digit(output_index)
            |> bytearray.concat(transaction_id, _)
            |> bytearray.concat(ret, _)
        },
      )
    |> crypto.blake2b_256
}

test succ_blake2b_256() {
  let utxo1 =
    Input {
      output_reference: OutputReference {
        transaction_id: "lastTxn",
        output_index: 0,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo2 =
    Input {
      output_reference: OutputReference {
        transaction_id: "mid",
        output_index: 0,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo3 =
    Input {
      output_reference: OutputReference {
        transaction_id: "beg",
        output_index: 0,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo4 =
    Input {
      output_reference: OutputReference {
        transaction_id: "lastTxn",
        output_index: 3,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo5 =
    Input {
      output_reference: OutputReference {
        transaction_id: "beg",
        output_index: 3,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  // blake2b_256([utxo1, utxo2, utxo3, utxo4, utxo5]) == crypto.blake2b_256(
  //   list.foldl(
  //     [utxo1, utxo2, utxo3, utxo4, utxo5],
  //     #"",
  //     fn(outref: Input, ret: ByteArray) -> ByteArray {
  //       outref.output_reference.transaction_id
  //         |> bytearray.concat(convert.int_to_digit(outref.output_reference.output_index))
  //         |> bytearray.concat(ret, _)
  //     },
  //   ),
  // )
  blake2b_256([utxo1, utxo2, utxo3, utxo4, utxo5]) == #"0eb64f44615884988f7f32d7fab886172d8bac004ebf5c815410f8a87c5cd54d"
}

pub fn blake2b_256_sort_asc(inputs: List<Input>) -> Blake2b256Hash {
  inputs |> sort.inputs_sort_asc |> blake2b_256
}

test succ_blake2b_256_sort_asc() {
  let utxo1 =
    Input {
      output_reference: OutputReference {
        transaction_id: "lastTxn",
        output_index: 0,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo2 =
    Input {
      output_reference: OutputReference {
        transaction_id: "mid",
        output_index: 0,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo3 =
    Input {
      output_reference: OutputReference {
        transaction_id: "beg",
        output_index: 0,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo4 =
    Input {
      output_reference: OutputReference {
        transaction_id: "lastTxn",
        output_index: 3,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo5 =
    Input {
      output_reference: OutputReference {
        transaction_id: "beg",
        output_index: 3,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  // blake2b_256_sort_asc([utxo1, utxo2, utxo3, utxo4, utxo5]) == crypto.blake2b_256(
  //   list.foldl(
  //     [utxo3, utxo2, utxo1, utxo5, utxo4, utxo4],
  //     #"",
  //     fn(outref: Input, ret: ByteArray) -> ByteArray {
  //       outref.output_reference.transaction_id
  //         |> bytearray.concat(convert.int_to_digit(outref.output_reference.output_index))
  //         |> bytearray.concat(ret, _)
  //     },
  //   ),
  // )
  blake2b_256_sort_asc([utxo1, utxo2, utxo3, utxo4, utxo5]) == #"7d162c7ea297a557904b98a0bf7282013f67b36c86120a41f2b8da2ea83af5b4"
}

pub fn blake2b_256_quicksort_asc(inputs: List<Input>) -> Blake2b256Hash {
  inputs |> sort.inputs_quicksort_asc |> blake2b_256
}

test succ_blake2b_256_quicksort_asc() {
  let utxo1 =
    Input {
      output_reference: OutputReference {
        transaction_id: "lastTxn",
        output_index: 0,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo2 =
    Input {
      output_reference: OutputReference {
        transaction_id: "mid",
        output_index: 0,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo3 =
    Input {
      output_reference: OutputReference {
        transaction_id: "beg",
        output_index: 0,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo4 =
    Input {
      output_reference: OutputReference {
        transaction_id: "lastTxn",
        output_index: 3,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo5 =
    Input {
      output_reference: OutputReference {
        transaction_id: "beg",
        output_index: 3,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  // blake2b_256_quicksort_asc([utxo1, utxo2, utxo3, utxo4, utxo5]) == crypto.blake2b_256(
  //   list.foldl(
  //     [utxo3, utxo2, utxo1, utxo5, utxo4, utxo4],
  //     #"",
  //     fn(outref: Input, ret: ByteArray) -> ByteArray {
  //       outref.output_reference.transaction_id
  //         |> bytearray.concat(convert.int_to_digit(outref.output_reference.output_index))
  //         |> bytearray.concat(ret, _)
  //     },
  //   ),
  // )
  blake2b_256_quicksort_asc([utxo1, utxo2, utxo3, utxo4, utxo5]) == #"7d162c7ea297a557904b98a0bf7282013f67b36c86120a41f2b8da2ea83af5b4"
}

pub fn blake2b_256_head_sort_asc(inputs: List<Input>) -> Blake2b256Hash {
  when inputs |> sort.inputs_sort_asc |> list.head is {
    Some(i) -> input_hash.blake2b_256(i)
    _ -> #""
  }
}

test succ_blake2b_256_head_sort_asc() {
  let utxo1 =
    Input {
      output_reference: OutputReference {
        transaction_id: "lastTxn",
        output_index: 1,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo2 =
    Input {
      output_reference: OutputReference {
        transaction_id: #"2b405c773982c6cddf1d8b8a80769a84851f3ce21febbb227777b3ba43be14f1",
        output_index: 0,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo3 =
    Input {
      output_reference: OutputReference {
        transaction_id: "beg",
        output_index: 1,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo4 =
    Input {
      output_reference: OutputReference {
        transaction_id: "lastTxn",
        output_index: 3,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo5 =
    Input {
      output_reference: OutputReference {
        transaction_id: "beg",
        output_index: 3,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  // blake2b_256_head_sort_asc([utxo1, utxo2, utxo3, utxo4, utxo5]) == crypto.blake2b_256(
  //   bytearray.concat(
  //     #"2b405c773982c6cddf1d8b8a80769a84851f3ce21febbb227777b3ba43be14f1",
  //     convert.int_to_digit(0),
  //   ),
  // )
  blake2b_256_head_sort_asc([utxo1, utxo2, utxo3, utxo4, utxo5]) == #"060f4c8b63d168305c5b020708cac4e7befe6063f83f68255cb9c207860c4410"
}

pub fn blake2b_256_last_sort_asc(inputs: List<Input>) -> Blake2b256Hash {
  when inputs |> sort.inputs_sort_asc |> list.last is {
    Some(i) -> input_hash.blake2b_256(i)
    _ -> #""
  }
}

test succ_blake2b_256_last_sort_asc() {
  let utxo1 =
    Input {
      output_reference: OutputReference {
        transaction_id: "lastTxn",
        output_index: 0,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo2 =
    Input {
      output_reference: OutputReference {
        transaction_id: "mid",
        output_index: 2,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo3 =
    Input {
      output_reference: OutputReference {
        transaction_id: "beg",
        output_index: 1,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo4 =
    Input {
      output_reference: OutputReference {
        transaction_id: "lastTxn",
        output_index: 3,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo5 =
    Input {
      output_reference: OutputReference {
        transaction_id: "beg",
        output_index: 3,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  // blake2b_256_last_sort_asc([utxo1, utxo2, utxo3, utxo4, utxo5]) == crypto.blake2b_256(
  //   bytearray.concat("lastTxn", convert.int_to_digit(3)),
  // )
  blake2b_256_last_sort_asc([utxo1, utxo2, utxo3, utxo4, utxo5]) == #"2d899c3cbad1a6b649d7381f38d30e41063eee0270675bc355f2a4f51ea91c46"
}

pub fn blake2b_256_salt_head_sort_asc(
  inputs: List<Input>,
  salt: ByteArray,
) -> Blake2b256Hash {
  when inputs |> sort.inputs_sort_asc |> list.head is {
    Some(i) -> input_hash.blake2b_256_salt(i, salt)
    _ -> #""
  }
}

test succ_blake2b_256_salt_head_sort_asc() {
  let salt = #"060f4c8b63d168305c5b020708cac4e7befe6063f83f68255cb9c207860c4410"
  let utxo1 =
    Input {
      output_reference: OutputReference {
        transaction_id: "lastTxn",
        output_index: 1,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo2 =
    Input {
      output_reference: OutputReference {
        transaction_id: #"2b405c773982c6cddf1d8b8a80769a84851f3ce21febbb227777b3ba43be14f1",
        output_index: 0,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo3 =
    Input {
      output_reference: OutputReference {
        transaction_id: "beg",
        output_index: 1,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo4 =
    Input {
      output_reference: OutputReference {
        transaction_id: "lastTxn",
        output_index: 3,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo5 =
    Input {
      output_reference: OutputReference {
        transaction_id: "beg",
        output_index: 3,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  // blake2b_256_salt_head_sort_asc([utxo1, utxo2, utxo3, utxo4, utxo5], salt) == crypto.blake2b_256(
  //   #"2b405c773982c6cddf1d8b8a80769a84851f3ce21febbb227777b3ba43be14f1"
  //     |> bytearray.concat(convert.int_to_digit(1))
  //     |> bytearray.concat(salt),
  // )
  blake2b_256_salt_head_sort_asc([utxo1, utxo2, utxo3, utxo4, utxo5], salt) == #"4ef8bc43b96a4d43955531b5db19e29d79c6aa205b11c64d686afe2e10289331"
}

pub fn blake2b_224(inputs: List<Input>) -> Blake2b224Hash {
  inputs
    |> list.foldl(
        #"",
        fn(
          Input {
            output_reference: OutputReference { transaction_id, output_index },
            ..
          }: Input,
          ret: ByteArray,
        ) -> ByteArray {
          convert.int_to_digit(output_index)
            |> bytearray.concat(transaction_id, _)
            |> bytearray.concat(ret, _)
        },
      )
    |> crypto.blake2b_224
}

test succ_blake2b_224() {
  let utxo1 =
    Input {
      output_reference: OutputReference {
        transaction_id: "lastTxn",
        output_index: 0,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo2 =
    Input {
      output_reference: OutputReference {
        transaction_id: "mid",
        output_index: 0,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo3 =
    Input {
      output_reference: OutputReference {
        transaction_id: "beg",
        output_index: 0,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo4 =
    Input {
      output_reference: OutputReference {
        transaction_id: "lastTxn",
        output_index: 3,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo5 =
    Input {
      output_reference: OutputReference {
        transaction_id: "beg",
        output_index: 3,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  // blake2b_224([utxo1, utxo2, utxo3, utxo4, utxo5]) == crypto.blake2b_224(
  //   list.foldl(
  //     [utxo1, utxo2, utxo3, utxo4, utxo5],
  //     #"",
  //     fn(outref: Input, ret: ByteArray) -> ByteArray {
  //       outref.output_reference.transaction_id
  //         |> bytearray.concat(convert.int_to_digit(outref.output_reference.output_index))
  //         |> bytearray.concat(ret, _)
  //     },
  //   ),
  // )
  blake2b_224([utxo1, utxo2, utxo3, utxo4, utxo5]) == #"3a2193b236081057b9bdbf9300274efed0cec5d64036a7172662b72e"
}

pub fn blake2b_224_sort_asc(inputs: List<Input>) -> Blake2b224Hash {
  inputs |> sort.inputs_sort_asc |> blake2b_224
}

test succ_blake2b_224_sort_asc() {
  let utxo1 =
    Input {
      output_reference: OutputReference {
        transaction_id: "lastTxn",
        output_index: 0,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo2 =
    Input {
      output_reference: OutputReference {
        transaction_id: "mid",
        output_index: 0,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo3 =
    Input {
      output_reference: OutputReference {
        transaction_id: "beg",
        output_index: 0,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo4 =
    Input {
      output_reference: OutputReference {
        transaction_id: "lastTxn",
        output_index: 3,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo5 =
    Input {
      output_reference: OutputReference {
        transaction_id: "beg",
        output_index: 3,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  // blake2b_224_sort_asc([utxo1, utxo2, utxo3, utxo4, utxo5]) == crypto.blake2b_224(
  //   list.foldl(
  //     [utxo3, utxo2, utxo1, utxo5, utxo4, utxo4],
  //     #"",
  //     fn(outref: Input, ret: ByteArray) -> ByteArray {
  //       outref.output_reference.transaction_id
  //         |> bytearray.concat(convert.int_to_digit(outref.output_reference.output_index))
  //         |> bytearray.concat(ret, _)
  //     },
  //   ),
  // )
  blake2b_224_sort_asc([utxo1, utxo2, utxo3, utxo4, utxo5]) == #"68f4e4777d5f1890d46595880c40907556457ed89f5edca42889f222"
}

pub fn blake2b_224_quicksort_asc(inputs: List<Input>) -> Blake2b224Hash {
  inputs |> sort.inputs_quicksort_asc |> blake2b_224
}

test succ_blake2b_224_quicksort_asc() {
  let utxo1 =
    Input {
      output_reference: OutputReference {
        transaction_id: "lastTxn",
        output_index: 0,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo2 =
    Input {
      output_reference: OutputReference {
        transaction_id: "mid",
        output_index: 0,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo3 =
    Input {
      output_reference: OutputReference {
        transaction_id: "beg",
        output_index: 0,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo4 =
    Input {
      output_reference: OutputReference {
        transaction_id: "lastTxn",
        output_index: 3,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo5 =
    Input {
      output_reference: OutputReference {
        transaction_id: "beg",
        output_index: 3,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  // blake2b_224_quicksort_asc([utxo1, utxo2, utxo3, utxo4, utxo5]) == crypto.blake2b_224(
  //   list.foldl(
  //     [utxo3, utxo2, utxo1, utxo5, utxo4, utxo4],
  //     #"",
  //     fn(outref: Input, ret: ByteArray) -> ByteArray {
  //       outref.output_reference.transaction_id
  //         |> bytearray.concat(convert.int_to_digit(outref.output_reference.output_index))
  //         |> bytearray.concat(ret, _)
  //     },
  //   ),
  // )
  blake2b_224_quicksort_asc([utxo1, utxo2, utxo3, utxo4, utxo5]) == #"68f4e4777d5f1890d46595880c40907556457ed89f5edca42889f222"
}

pub fn blake2b_224_head_sort_asc(inputs: List<Input>) -> Blake2b224Hash {
  when inputs |> sort.inputs_sort_asc |> list.head is {
    Some(i) -> input_hash.blake2b_224(i)
    _ -> #""
  }
}

test succ_blake2b_224_head_sort_asc() {
  let utxo1 =
    Input {
      output_reference: OutputReference {
        transaction_id: "lastTxn",
        output_index: 1,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo2 =
    Input {
      output_reference: OutputReference {
        transaction_id: #"2b405c773982c6cddf1d8b8a80769a84851f3ce21febbb227777b3ba43be14f1",
        output_index: 0,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo3 =
    Input {
      output_reference: OutputReference {
        transaction_id: "beg",
        output_index: 1,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo4 =
    Input {
      output_reference: OutputReference {
        transaction_id: "lastTxn",
        output_index: 3,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo5 =
    Input {
      output_reference: OutputReference {
        transaction_id: "beg",
        output_index: 3,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  // blake2b_224_head_sort_asc([utxo1, utxo2, utxo3, utxo4, utxo5]) == crypto.blake2b_224(
  //   bytearray.concat(
  //     #"2b405c773982c6cddf1d8b8a80769a84851f3ce21febbb227777b3ba43be14f1",
  //     convert.int_to_digit(0),
  //   ),
  // )
  blake2b_224_head_sort_asc([utxo1, utxo2, utxo3, utxo4, utxo5]) == #"678cbdecaf56ed9a528555ca1a31decdd4cc35d385956905b2eff9fc"
}

pub fn blake2b_224_last_sort_asc(inputs: List<Input>) -> Blake2b224Hash {
  when inputs |> sort.inputs_sort_asc |> list.last is {
    Some(i) -> input_hash.blake2b_224(i)
    _ -> #""
  }
}

test succ_blake2b_224_last_sort_asc() {
  let utxo1 =
    Input {
      output_reference: OutputReference {
        transaction_id: "lastTxn",
        output_index: 0,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo2 =
    Input {
      output_reference: OutputReference {
        transaction_id: "mid",
        output_index: 2,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo3 =
    Input {
      output_reference: OutputReference {
        transaction_id: "beg",
        output_index: 1,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo4 =
    Input {
      output_reference: OutputReference {
        transaction_id: "lastTxn",
        output_index: 3,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo5 =
    Input {
      output_reference: OutputReference {
        transaction_id: "beg",
        output_index: 3,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  // blake2b_224_last_sort_asc([utxo1, utxo2, utxo3, utxo4, utxo5]) == crypto.blake2b_224(
  //   bytearray.concat("lastTxn", convert.int_to_digit(3)),
  // )
  blake2b_224_last_sort_asc([utxo1, utxo2, utxo3, utxo4, utxo5]) == #"4ae75be874e9ef95c001bfd21c12ff29a7bd8186ff9fcb2313c566a0"
}

pub fn blake2b_224_salt_head_sort_asc(
  inputs: List<Input>,
  salt: ByteArray,
) -> Blake2b224Hash {
  when inputs |> sort.inputs_sort_asc |> list.head is {
    Some(i) -> input_hash.blake2b_224_salt(i, salt)
    _ -> #""
  }
}

test succ_blake2b_224_salt_head_sort_asc() {
  let salt = #"060f4c8b63d168305c5b020708cac4e7befe6063f83f68255cb9c207860c4410"
  let utxo1 =
    Input {
      output_reference: OutputReference {
        transaction_id: "lastTxn",
        output_index: 1,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo2 =
    Input {
      output_reference: OutputReference {
        transaction_id: #"2b405c773982c6cddf1d8b8a80769a84851f3ce21febbb227777b3ba43be14f1",
        output_index: 0,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo3 =
    Input {
      output_reference: OutputReference {
        transaction_id: "beg",
        output_index: 1,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo4 =
    Input {
      output_reference: OutputReference {
        transaction_id: "lastTxn",
        output_index: 3,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo5 =
    Input {
      output_reference: OutputReference {
        transaction_id: "beg",
        output_index: 3,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  // blake2b_224_salt_head_sort_asc([utxo1, utxo2, utxo3, utxo4, utxo5], salt) == crypto.blake2b_224(
  //   #"2b405c773982c6cddf1d8b8a80769a84851f3ce21febbb227777b3ba43be14f1"
  //     |> bytearray.concat(convert.int_to_digit(1))
  //     |> bytearray.concat(salt),
  // )
  blake2b_224_salt_head_sort_asc([utxo1, utxo2, utxo3, utxo4, utxo5], salt) == #"c1c575d1743e03a69399fb61a530f8c672df3b9e8d8f0aafa7257cf4"
}
