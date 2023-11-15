use aiken/builtin.{cons_bytearray, quotient_integer, remainder_integer}
use aiken/bytearray.{concat}
use aiken/hash.{Blake2b_256, Hash, blake2b_256}
use aiken/list
use aiken/transaction.{OutputReference, TransactionId}

pub fn hash_tx_outrefs(
  outrefs: List<OutputReference>,
) -> Hash<Blake2b_256, ByteArray> {
  let sorted =
    list.sort(
      outrefs,
      fn(a: OutputReference, b: OutputReference) -> Ordering {
        if a.output_index < b.output_index {
          Less
        } else if a.output_index == b.output_index {
          Equal
        } else {
          Greater
        }
      },
    )
  blake2b_256(
    list.foldl(
      sorted,
      #"",
      fn(outref: OutputReference, ret: ByteArray) -> ByteArray {
        outref.transaction_id.hash
          |> concat(int_to_digit(outref.output_index))
          |> concat(ret, _)
      },
    ),
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

test test_hash_ref() {
  let utxo =
    OutputReference {
      transaction_id: TransactionId { hash: "lastTxn" },
      output_index: 2894,
    }
  let utxo2 =
    OutputReference {
      transaction_id: TransactionId { hash: "mid" },
      output_index: 1,
    }
  let utxo3 =
    OutputReference {
      transaction_id: TransactionId { hash: "beg" },
      output_index: 0,
    }
  hash_tx_outrefs([utxo, utxo2, utxo3]) == blake2b_256("beg0mid1lastTxn2894")
}

test test_int_to_digit() {
  int_to_digit(12) == "12" && int_to_digit(0) == "0"
}
