use aiken/bytearray
use aiken/hash.{Blake2b_256, Hash, blake2b_256}
use aiken/list
use aiken/transaction.{Input, NoDatum, Output, OutputReference, TransactionId}
use aiken/transaction/credential.{from_script}
use aiken/transaction/value
use common/convert

pub fn inputs_contain_outref(
  inputs: List<Input>,
  outref: OutputReference,
) -> Bool {
  list.any(inputs, fn(i) -> Bool { i.output_reference == outref })
}

pub fn hash_inputs(inputs: List<Input>) -> Hash<Blake2b_256, ByteArray> {
  blake2b_256(
    list.foldl(
      inputs,
      #"",
      fn(i: Input, ret: ByteArray) -> ByteArray {
        i.output_reference.transaction_id.hash
          |> bytearray.concat(
               convert.int_to_digit(i.output_reference.output_index),
             )
          |> bytearray.concat(ret, _)
      },
    ),
  )
}

pub fn sort_asc_inputs(inputs: List<Input>) -> List<Input> {
  list.sort(
    inputs,
    fn(a: Input, b: Input) -> Ordering {
      if a.output_reference.output_index < b.output_reference.output_index {
        Less
      } else if a.output_reference.output_index == b.output_reference.output_index {
        Equal
      } else {
        Greater
      }
    },
  )
}

pub fn quicksort_asc_inputs(inputs: List<Input>) -> List<Input> {
  when inputs is {
    [] ->
      []
    [p, ..tail] -> {
      let before =
        tail
          |> list.filter(
               fn(x) {
                 x.output_reference.output_index <= p.output_reference.output_index
               },
             )
          |> quicksort_asc_inputs
      let after =
        tail
          |> list.filter(
               fn(x) {
                 x.output_reference.output_index > p.output_reference.output_index
               },
             )
          |> quicksort_asc_inputs
      list.concat(before, [p, ..after])
    }
  }
}

pub fn hash_inputs_sort_asc(inputs: List<Input>) -> Hash<Blake2b_256, ByteArray> {
  hash_inputs(sort_asc_inputs(inputs))
}

pub fn hash_inputs_quicksort_asc(
  inputs: List<Input>,
) -> Hash<Blake2b_256, ByteArray> {
  hash_inputs(quicksort_asc_inputs(inputs))
}

test succ_hash_inputs_not_sort() {
  let utxo1 =
    Input {
      output_reference: OutputReference {
        transaction_id: TransactionId { hash: "lastTxn" },
        output_index: 0,
      },
      output: Output {
        address: from_script(#""),
        value: value.zero(),
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo2 =
    Input {
      output_reference: OutputReference {
        transaction_id: TransactionId { hash: "mid" },
        output_index: 0,
      },
      output: Output {
        address: from_script(#""),
        value: value.zero(),
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo3 =
    Input {
      output_reference: OutputReference {
        transaction_id: TransactionId { hash: "beg" },
        output_index: 0,
      },
      output: Output {
        address: from_script(#""),
        value: value.zero(),
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo4 =
    Input {
      output_reference: OutputReference {
        transaction_id: TransactionId { hash: "lastTxn" },
        output_index: 3,
      },
      output: Output {
        address: from_script(#""),
        value: value.zero(),
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo5 =
    Input {
      output_reference: OutputReference {
        transaction_id: TransactionId { hash: "beg" },
        output_index: 3,
      },
      output: Output {
        address: from_script(#""),
        value: value.zero(),
        datum: NoDatum,
        reference_script: None,
      },
    }
  // hash_inputs([utxo1, utxo2, utxo3, utxo4, utxo5]) == blake2b_256(
  //   list.foldl(
  //     [utxo1, utxo2, utxo3, utxo4, utxo5],
  //     #"",
  //     fn(outref: Input, ret: ByteArray) -> ByteArray {
  //       outref.output_reference.transaction_id.hash
  //         |> bytearray.concat(convert.int_to_digit(outref.output_reference.output_index))
  //         |> bytearray.concat(ret, _)
  //     },
  //   ),
  // )
  hash_inputs([utxo1, utxo2, utxo3, utxo4, utxo5]) == #"0eb64f44615884988f7f32d7fab886172d8bac004ebf5c815410f8a87c5cd54d"
}

test succ_hash_inputs_sort_asc() {
  let utxo1 =
    Input {
      output_reference: OutputReference {
        transaction_id: TransactionId { hash: "lastTxn" },
        output_index: 0,
      },
      output: Output {
        address: from_script(#""),
        value: value.zero(),
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo2 =
    Input {
      output_reference: OutputReference {
        transaction_id: TransactionId { hash: "mid" },
        output_index: 0,
      },
      output: Output {
        address: from_script(#""),
        value: value.zero(),
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo3 =
    Input {
      output_reference: OutputReference {
        transaction_id: TransactionId { hash: "beg" },
        output_index: 0,
      },
      output: Output {
        address: from_script(#""),
        value: value.zero(),
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo4 =
    Input {
      output_reference: OutputReference {
        transaction_id: TransactionId { hash: "lastTxn" },
        output_index: 3,
      },
      output: Output {
        address: from_script(#""),
        value: value.zero(),
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo5 =
    Input {
      output_reference: OutputReference {
        transaction_id: TransactionId { hash: "beg" },
        output_index: 3,
      },
      output: Output {
        address: from_script(#""),
        value: value.zero(),
        datum: NoDatum,
        reference_script: None,
      },
    }
  // hash_inputs_sort_asc([utxo1, utxo2, utxo3, utxo4, utxo5]) == blake2b_256(
  //   list.foldl(
  //     [utxo3, utxo2, utxo1, utxo5, utxo4, utxo4],
  //     #"",
  //     fn(outref: Input, ret: ByteArray) -> ByteArray {
  //       outref.output_reference.transaction_id.hash
  //         |> bytearray.concat(convert.int_to_digit(outref.output_reference.output_index))
  //         |> bytearray.concat(ret, _)
  //     },
  //   ),
  // )
  hash_inputs_sort_asc([utxo1, utxo2, utxo3, utxo4, utxo5]) == #"7d162c7ea297a557904b98a0bf7282013f67b36c86120a41f2b8da2ea83af5b4"
}

test succ_hash_inputs_quicksort_asc() {
  let utxo1 =
    Input {
      output_reference: OutputReference {
        transaction_id: TransactionId { hash: "lastTxn" },
        output_index: 0,
      },
      output: Output {
        address: from_script(#""),
        value: value.zero(),
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo2 =
    Input {
      output_reference: OutputReference {
        transaction_id: TransactionId { hash: "mid" },
        output_index: 0,
      },
      output: Output {
        address: from_script(#""),
        value: value.zero(),
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo3 =
    Input {
      output_reference: OutputReference {
        transaction_id: TransactionId { hash: "beg" },
        output_index: 0,
      },
      output: Output {
        address: from_script(#""),
        value: value.zero(),
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo4 =
    Input {
      output_reference: OutputReference {
        transaction_id: TransactionId { hash: "lastTxn" },
        output_index: 3,
      },
      output: Output {
        address: from_script(#""),
        value: value.zero(),
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo5 =
    Input {
      output_reference: OutputReference {
        transaction_id: TransactionId { hash: "beg" },
        output_index: 3,
      },
      output: Output {
        address: from_script(#""),
        value: value.zero(),
        datum: NoDatum,
        reference_script: None,
      },
    }
  // hash_inputs_quicksort_asc([utxo1, utxo2, utxo3, utxo4, utxo5]) == blake2b_256(
  //   list.foldl(
  //     [utxo3, utxo2, utxo1, utxo5, utxo4, utxo4],
  //     #"",
  //     fn(outref: Input, ret: ByteArray) -> ByteArray {
  //       outref.output_reference.transaction_id.hash
  //         |> bytearray.concat(convert.int_to_digit(outref.output_reference.output_index))
  //         |> bytearray.concat(ret, _)
  //     },
  //   ),
  // )
  hash_inputs_quicksort_asc([utxo1, utxo2, utxo3, utxo4, utxo5]) == #"7d162c7ea297a557904b98a0bf7282013f67b36c86120a41f2b8da2ea83af5b4"
}

pub fn hash_input(i: Input) -> Hash<Blake2b_256, ByteArray> {
  blake2b_256(
    i.output_reference.transaction_id.hash
      |> bytearray.concat(convert.int_to_digit(i.output_reference.output_index)),
  )
}

test succ_hash_input() {
  let utxo1 =
    Input {
      output_reference: OutputReference {
        transaction_id: TransactionId {
          hash: #"2b405c773982c6cddf1d8b8a80769a84851f3ce21febbb227777b3ba43be14f1",
        },
        output_index: 0,
      },
      output: Output {
        address: from_script(#""),
        value: value.zero(),
        datum: NoDatum,
        reference_script: None,
      },
    }
  // hash_input(utxo1) == blake2b_256(
  //   bytearray.concat(
  //     #"2b405c773982c6cddf1d8b8a80769a84851f3ce21febbb227777b3ba43be14f1",
  //     convert.int_to_digit(0),
  //   ),
  // )
  hash_input(utxo1) == #"060f4c8b63d168305c5b020708cac4e7befe6063f83f68255cb9c207860c4410"
}

pub fn hash_inputs_head_sort_asc(
  inputs: List<Input>,
) -> Hash<Blake2b_256, ByteArray> {
  when list.head(sort_asc_inputs(inputs)) is {
    Some(i) -> hash_input(i)
    _ -> fail @"not found input"
  }
}

test succ_hash_inputs_head_sort_asc() {
  let utxo1 =
    Input {
      output_reference: OutputReference {
        transaction_id: TransactionId { hash: "lastTxn" },
        output_index: 1,
      },
      output: Output {
        address: from_script(#""),
        value: value.zero(),
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo2 =
    Input {
      output_reference: OutputReference {
        transaction_id: TransactionId {
          hash: #"2b405c773982c6cddf1d8b8a80769a84851f3ce21febbb227777b3ba43be14f1",
        },
        output_index: 0,
      },
      output: Output {
        address: from_script(#""),
        value: value.zero(),
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo3 =
    Input {
      output_reference: OutputReference {
        transaction_id: TransactionId { hash: "beg" },
        output_index: 1,
      },
      output: Output {
        address: from_script(#""),
        value: value.zero(),
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo4 =
    Input {
      output_reference: OutputReference {
        transaction_id: TransactionId { hash: "lastTxn" },
        output_index: 3,
      },
      output: Output {
        address: from_script(#""),
        value: value.zero(),
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo5 =
    Input {
      output_reference: OutputReference {
        transaction_id: TransactionId { hash: "beg" },
        output_index: 3,
      },
      output: Output {
        address: from_script(#""),
        value: value.zero(),
        datum: NoDatum,
        reference_script: None,
      },
    }
  // hash_inputs_head_sort_asc([utxo1, utxo2, utxo3, utxo4, utxo5]) == blake2b_256(
  //   bytearray.concat(
  //     #"2b405c773982c6cddf1d8b8a80769a84851f3ce21febbb227777b3ba43be14f1",
  //     convert.int_to_digit(0),
  //   ),
  // )
  hash_inputs_head_sort_asc([utxo1, utxo2, utxo3, utxo4, utxo5]) == #"060f4c8b63d168305c5b020708cac4e7befe6063f83f68255cb9c207860c4410"
}

pub fn hash_inputs_last_sort_asc(
  inputs: List<Input>,
) -> Hash<Blake2b_256, ByteArray> {
  when list.last(sort_asc_inputs(inputs)) is {
    Some(i) -> hash_input(i)
    _ -> fail @"not found input"
  }
}

test succ_hash_inputs_last_sort_asc() {
  let utxo1 =
    Input {
      output_reference: OutputReference {
        transaction_id: TransactionId { hash: "lastTxn" },
        output_index: 0,
      },
      output: Output {
        address: from_script(#""),
        value: value.zero(),
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo2 =
    Input {
      output_reference: OutputReference {
        transaction_id: TransactionId { hash: "mid" },
        output_index: 2,
      },
      output: Output {
        address: from_script(#""),
        value: value.zero(),
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo3 =
    Input {
      output_reference: OutputReference {
        transaction_id: TransactionId { hash: "beg" },
        output_index: 1,
      },
      output: Output {
        address: from_script(#""),
        value: value.zero(),
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo4 =
    Input {
      output_reference: OutputReference {
        transaction_id: TransactionId { hash: "lastTxn" },
        output_index: 3,
      },
      output: Output {
        address: from_script(#""),
        value: value.zero(),
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo5 =
    Input {
      output_reference: OutputReference {
        transaction_id: TransactionId { hash: "beg" },
        output_index: 3,
      },
      output: Output {
        address: from_script(#""),
        value: value.zero(),
        datum: NoDatum,
        reference_script: None,
      },
    }
  // hash_inputs_last_sort_asc([utxo1, utxo2, utxo3, utxo4, utxo5]) == blake2b_256(
  //   bytearray.concat("lastTxn", convert.int_to_digit(3)),
  // )
  hash_inputs_last_sort_asc([utxo1, utxo2, utxo3, utxo4, utxo5]) == #"2d899c3cbad1a6b649d7381f38d30e41063eee0270675bc355f2a4f51ea91c46"
}

pub fn hash_input_salt(
  i: Input,
  salt: ByteArray,
) -> Hash<Blake2b_256, ByteArray> {
  blake2b_256(
    i.output_reference.transaction_id.hash
      |> bytearray.concat(convert.int_to_digit(i.output_reference.output_index))
      |> bytearray.concat(salt),
  )
}

test succ_hash_input_salt() {
  let salt = #"d53d658b5f7eac3f741389135662a2bf9f2475844141705a5c0514f81e47f9bf"
  let utxo1 =
    Input {
      output_reference: OutputReference {
        transaction_id: TransactionId {
          hash: #"23850612667a59e236ceeea412440b446fa697f2b988eb05e070aaa18c8cad0f",
        },
        output_index: 0,
      },
      output: Output {
        address: from_script(#""),
        value: value.zero(),
        datum: NoDatum,
        reference_script: None,
      },
    }
  // hash_input_salt(utxo1, salt) == blake2b_256(
  //   #"23850612667a59e236ceeea412440b446fa697f2b988eb05e070aaa18c8cad0f30d53d658b5f7eac3f741389135662a2bf9f2475844141705a5c0514f81e47f9bf",
  // )
  hash_input_salt(utxo1, salt) == #"79b18aded9e04c72f38e5fa8c4b31a0f3dc83d47f9ad5cdc2eed3f22f477247e"
}

pub fn hash_inputs_head_salt_sort_asc(
  inputs: List<Input>,
  salt: ByteArray,
) -> Hash<Blake2b_256, ByteArray> {
  when list.head(sort_asc_inputs(inputs)) is {
    Some(i) -> hash_input_salt(i, salt)
    None -> fail @"not found input"
  }
}

test succ_hash_inputs_head_salt_sort_asc() {
  let salt = #"060f4c8b63d168305c5b020708cac4e7befe6063f83f68255cb9c207860c4410"
  let utxo1 =
    Input {
      output_reference: OutputReference {
        transaction_id: TransactionId { hash: "lastTxn" },
        output_index: 1,
      },
      output: Output {
        address: from_script(#""),
        value: value.zero(),
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo2 =
    Input {
      output_reference: OutputReference {
        transaction_id: TransactionId {
          hash: #"2b405c773982c6cddf1d8b8a80769a84851f3ce21febbb227777b3ba43be14f1",
        },
        output_index: 0,
      },
      output: Output {
        address: from_script(#""),
        value: value.zero(),
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo3 =
    Input {
      output_reference: OutputReference {
        transaction_id: TransactionId { hash: "beg" },
        output_index: 1,
      },
      output: Output {
        address: from_script(#""),
        value: value.zero(),
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo4 =
    Input {
      output_reference: OutputReference {
        transaction_id: TransactionId { hash: "lastTxn" },
        output_index: 3,
      },
      output: Output {
        address: from_script(#""),
        value: value.zero(),
        datum: NoDatum,
        reference_script: None,
      },
    }
  let utxo5 =
    Input {
      output_reference: OutputReference {
        transaction_id: TransactionId { hash: "beg" },
        output_index: 3,
      },
      output: Output {
        address: from_script(#""),
        value: value.zero(),
        datum: NoDatum,
        reference_script: None,
      },
    }
  // hash_inputs_head_salt_sort_asc([utxo1, utxo2, utxo3, utxo4, utxo5], salt) == blake2b_256(
  //   #"2b405c773982c6cddf1d8b8a80769a84851f3ce21febbb227777b3ba43be14f1"
  //     |> bytearray.concat(convert.int_to_digit(1))
  //     |> bytearray.concat(salt),
  // )
  hash_inputs_head_salt_sort_asc([utxo1, utxo2, utxo3, utxo4, utxo5], salt) == #"4ef8bc43b96a4d43955531b5db19e29d79c6aa205b11c64d686afe2e10289331"
}
