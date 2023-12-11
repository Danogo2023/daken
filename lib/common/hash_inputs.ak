use aiken/builtin.{cons_bytearray, quotient_integer, remainder_integer}
use aiken/bytearray.{concat}
use aiken/hash.{Blake2b_256, Hash, blake2b_256}
use aiken/list
use aiken/transaction.{Input, NoDatum, Output, OutputReference, TransactionId}
use aiken/transaction/credential.{from_script}
use aiken/transaction/value

pub fn inputs_contain_outref(
  inputs: List<Input>,
  outref: OutputReference,
) -> Bool {
  list.any(inputs, fn(i) -> Bool { i.output_reference == outref })
}

pub fn sort_inputs(inputs: List<Input>) -> List<Input> {
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

pub fn hash_sorted_all(inputs: List<Input>) -> Hash<Blake2b_256, ByteArray> {
  blake2b_256(
    list.foldl(
      inputs,
      #"",
      fn(i: Input, ret: ByteArray) -> ByteArray {
        i.output_reference.transaction_id.hash
          |> concat(int_to_digit(i.output_reference.output_index))
          |> concat(ret, _)
      },
    ),
  )
}

pub fn hash_all(inputs: List<Input>) -> Hash<Blake2b_256, ByteArray> {
  hash_sorted_all(sort_inputs(inputs))
}

test test_hash_all() {
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
  hash_all([utxo1, utxo2, utxo3, utxo4, utxo5]) == blake2b_256(
    list.foldl(
      [utxo3, utxo2, utxo1, utxo5, utxo4],
      #"",
      fn(outref: Input, ret: ByteArray) -> ByteArray {
        outref.output_reference.transaction_id.hash
          |> concat(int_to_digit(outref.output_reference.output_index))
          |> concat(ret, _)
      },
    ),
  )
}

pub fn hash_sorted(input: Option<Input>) -> Hash<Blake2b_256, ByteArray> {
  when input is {
    Some(i) ->
      blake2b_256(
        i.output_reference.transaction_id.hash
          |> concat(int_to_digit(i.output_reference.output_index)),
      )
    _ -> fail @"not found input"
  }
}

pub fn hash_head(inputs: List<Input>) -> Hash<Blake2b_256, ByteArray> {
  hash_sorted(list.head(sort_inputs(inputs)))
}

test test_hash_head() {
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
  hash_head([utxo1, utxo2, utxo3, utxo4, utxo5]) == blake2b_256(
    concat(
      #"2b405c773982c6cddf1d8b8a80769a84851f3ce21febbb227777b3ba43be14f1",
      int_to_digit(0),
    ),
  )
}

pub fn hash_last(inputs: List<Input>) -> Hash<Blake2b_256, ByteArray> {
  hash_sorted(list.last(sort_inputs(inputs)))
}

test test_hash_last() {
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
  hash_last([utxo1, utxo2, utxo3, utxo4, utxo5]) == blake2b_256(
    concat("lastTxn", int_to_digit(3)),
  )
}

pub fn hash_sorted_salt(
  input: Option<Input>,
  salt: ByteArray,
) -> Hash<Blake2b_256, ByteArray> {
  when input is {
    Some(i) ->
      blake2b_256(
        i.output_reference.transaction_id.hash
          |> concat(int_to_digit(i.output_reference.output_index))
          |> concat(salt),
      )
    _ -> fail @"not found input"
  }
}

pub fn hash_head_salt(
  inputs: List<Input>,
  salt: ByteArray,
) -> Hash<Blake2b_256, ByteArray> {
  hash_sorted_salt(list.head(sort_inputs(inputs)), salt)
}

test test_hash_head_salt() {
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
  hash_head_salt([utxo1, utxo2, utxo3, utxo4, utxo5], salt) == blake2b_256(
    #"2b405c773982c6cddf1d8b8a80769a84851f3ce21febbb227777b3ba43be14f1"
      |> concat(int_to_digit(0))
      |> concat(salt),
  )
}

/// this function only work for i >= 0
fn int_to_digit(i: Int) -> ByteArray {
  if i < 0 {
    fail
  } else if i == 0 {
    "0"
  } else {
    do_int_to_digit(
      quotient_integer(i, 10),
      cons_bytearray(remainder_integer(i, 10) + 48, ""),
    )
  }
}

fn do_int_to_digit(i: Int, digits: ByteArray) -> ByteArray {
  if i <= 0 {
    digits
  } else {
    do_int_to_digit(
      quotient_integer(i, 10),
      cons_bytearray(remainder_integer(i, 10) + 48, digits),
    )
  }
}

test test_int_to_digit() {
  int_to_digit(12) == "12" && int_to_digit(0) == "0"
}
