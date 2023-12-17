use aiken/bytearray
use aiken/hash.{Blake2b_256, Hash, blake2b_256}
use aiken/list
use aiken/transaction.{OutputReference, TransactionId}
use common/convert

pub fn hash_out_refs(
  out_refs: List<OutputReference>,
) -> Hash<Blake2b_256, ByteArray> {
  blake2b_256(
    list.foldl(
      out_refs,
      #"",
      fn(o: OutputReference, ret: ByteArray) -> ByteArray {
        o.transaction_id.hash
          |> bytearray.concat(convert.int_to_digit(o.output_index))
          |> bytearray.concat(ret, _)
      },
    ),
  )
}

pub fn sort_asc_out_refs(
  out_refs: List<OutputReference>,
) -> List<OutputReference> {
  list.sort(
    out_refs,
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
}

pub fn quicksort_asc_out_refs(
  out_refs: List<OutputReference>,
) -> List<OutputReference> {
  when out_refs is {
    [] ->
      []
    [p, ..tail] -> {
      let before =
        tail
          |> list.filter(fn(x) { x.output_index <= p.output_index })
          |> quicksort_asc_out_refs
      let after =
        tail
          |> list.filter(fn(x) { x.output_index > p.output_index })
          |> quicksort_asc_out_refs
      list.concat(before, [p, ..after])
    }
  }
}

pub fn hash_out_refs_sort_asc(
  out_refs: List<OutputReference>,
) -> Hash<Blake2b_256, ByteArray> {
  hash_out_refs(sort_asc_out_refs(out_refs))
}

pub fn hash_out_refs_quicksort_asc(
  out_refs: List<OutputReference>,
) -> Hash<Blake2b_256, ByteArray> {
  hash_out_refs(quicksort_asc_out_refs(out_refs))
}

test succ_hash_out_refs_not_sort() {
  let out_ref_1 =
    OutputReference {
      transaction_id: TransactionId { hash: "lastTxn" },
      output_index: 0,
    }
  let out_ref_2 =
    OutputReference {
      transaction_id: TransactionId { hash: "mid" },
      output_index: 0,
    }
  let out_ref_3 =
    OutputReference {
      transaction_id: TransactionId { hash: "beg" },
      output_index: 0,
    }
  let out_ref_4 =
    OutputReference {
      transaction_id: TransactionId { hash: "lastTxn" },
      output_index: 3,
    }
  let out_ref_5 =
    OutputReference {
      transaction_id: TransactionId { hash: "beg" },
      output_index: 3,
    }
  hash_out_refs([out_ref_1, out_ref_2, out_ref_3, out_ref_4, out_ref_5]) == #"0eb64f44615884988f7f32d7fab886172d8bac004ebf5c815410f8a87c5cd54d"
}

test succ_hash_out_refs_sort_asc() {
  let out_ref_1 =
    OutputReference {
      transaction_id: TransactionId { hash: "lastTxn" },
      output_index: 0,
    }
  let out_ref_2 =
    OutputReference {
      transaction_id: TransactionId { hash: "mid" },
      output_index: 0,
    }
  let out_ref_3 =
    OutputReference {
      transaction_id: TransactionId { hash: "beg" },
      output_index: 0,
    }
  let out_ref_4 =
    OutputReference {
      transaction_id: TransactionId { hash: "lastTxn" },
      output_index: 3,
    }
  let out_ref_5 =
    OutputReference {
      transaction_id: TransactionId { hash: "beg" },
      output_index: 3,
    }
  hash_out_refs_sort_asc(
    [out_ref_1, out_ref_2, out_ref_3, out_ref_4, out_ref_5],
  ) == #"7d162c7ea297a557904b98a0bf7282013f67b36c86120a41f2b8da2ea83af5b4"
}

test succ_hash_out_refs_quicksort_asc() {
  let out_ref_1 =
    OutputReference {
      transaction_id: TransactionId { hash: "lastTxn" },
      output_index: 0,
    }
  let out_ref_2 =
    OutputReference {
      transaction_id: TransactionId { hash: "mid" },
      output_index: 0,
    }
  let out_ref_3 =
    OutputReference {
      transaction_id: TransactionId { hash: "beg" },
      output_index: 0,
    }
  let out_ref_4 =
    OutputReference {
      transaction_id: TransactionId { hash: "lastTxn" },
      output_index: 3,
    }
  let out_ref_5 =
    OutputReference {
      transaction_id: TransactionId { hash: "beg" },
      output_index: 3,
    }
  hash_out_refs_quicksort_asc(
    [out_ref_1, out_ref_2, out_ref_3, out_ref_4, out_ref_5],
  ) == #"7d162c7ea297a557904b98a0bf7282013f67b36c86120a41f2b8da2ea83af5b4"
}

pub fn hash_out_ref(i: OutputReference) -> Hash<Blake2b_256, ByteArray> {
  blake2b_256(
    i.transaction_id.hash
      |> bytearray.concat(convert.int_to_digit(i.output_index)),
  )
}

test succ_hash_out_ref() {
  let out_ref_1 =
    OutputReference {
      transaction_id: TransactionId {
        hash: #"2b405c773982c6cddf1d8b8a80769a84851f3ce21febbb227777b3ba43be14f1",
      },
      output_index: 0,
    }
  hash_out_ref(out_ref_1) == #"060f4c8b63d168305c5b020708cac4e7befe6063f83f68255cb9c207860c4410"
}

pub fn hash_out_refs_head_sort_asc(
  out_refs: List<OutputReference>,
) -> Hash<Blake2b_256, ByteArray> {
  when list.head(sort_asc_out_refs(out_refs)) is {
    Some(i) -> hash_out_ref(i)
    _ -> fail @"not found input"
  }
}

test succ_hash_out_refs_head_sort_asc() {
  let out_ref_1 =
    OutputReference {
      transaction_id: TransactionId { hash: "lastTxn" },
      output_index: 1,
    }
  let out_ref_2 =
    OutputReference {
      transaction_id: TransactionId {
        hash: #"2b405c773982c6cddf1d8b8a80769a84851f3ce21febbb227777b3ba43be14f1",
      },
      output_index: 0,
    }
  let out_ref_3 =
    OutputReference {
      transaction_id: TransactionId { hash: "beg" },
      output_index: 1,
    }
  let out_ref_4 =
    OutputReference {
      transaction_id: TransactionId { hash: "lastTxn" },
      output_index: 3,
    }
  let out_ref_5 =
    OutputReference {
      transaction_id: TransactionId { hash: "beg" },
      output_index: 3,
    }
  hash_out_refs_head_sort_asc(
    [out_ref_1, out_ref_2, out_ref_3, out_ref_4, out_ref_5],
  ) == #"060f4c8b63d168305c5b020708cac4e7befe6063f83f68255cb9c207860c4410"
}

pub fn hash_out_refs_last_sort_asc(
  out_refs: List<OutputReference>,
) -> Hash<Blake2b_256, ByteArray> {
  when list.last(sort_asc_out_refs(out_refs)) is {
    Some(i) -> hash_out_ref(i)
    _ -> fail @"not found input"
  }
}

test succ_hash_out_refs_last_sort_asc() {
  let out_ref_1 =
    OutputReference {
      transaction_id: TransactionId { hash: "lastTxn" },
      output_index: 0,
    }
  let out_ref_2 =
    OutputReference {
      transaction_id: TransactionId { hash: "mid" },
      output_index: 2,
    }
  let out_ref_3 =
    OutputReference {
      transaction_id: TransactionId { hash: "beg" },
      output_index: 1,
    }
  let out_ref_4 =
    OutputReference {
      transaction_id: TransactionId { hash: "lastTxn" },
      output_index: 3,
    }
  let out_ref_5 =
    OutputReference {
      transaction_id: TransactionId { hash: "beg" },
      output_index: 3,
    }
  hash_out_refs_last_sort_asc(
    [out_ref_1, out_ref_2, out_ref_3, out_ref_4, out_ref_5],
  ) == #"2d899c3cbad1a6b649d7381f38d30e41063eee0270675bc355f2a4f51ea91c46"
}

pub fn hash_out_ref_salt(
  i: OutputReference,
  salt: ByteArray,
) -> Hash<Blake2b_256, ByteArray> {
  blake2b_256(
    i.transaction_id.hash
      |> bytearray.concat(convert.int_to_digit(i.output_index))
      |> bytearray.concat(salt),
  )
}

test succ_hash_out_ref_salt() {
  let salt = #"d53d658b5f7eac3f741389135662a2bf9f2475844141705a5c0514f81e47f9bf"
  let out_ref_1 =
    OutputReference {
      transaction_id: TransactionId {
        hash: #"23850612667a59e236ceeea412440b446fa697f2b988eb05e070aaa18c8cad0f",
      },
      output_index: 0,
    }
  // hash_out_ref_salt(out_ref_1, salt) == blake2b_256(
  //   #"23850612667a59e236ceeea412440b446fa697f2b988eb05e070aaa18c8cad0f30d53d658b5f7eac3f741389135662a2bf9f2475844141705a5c0514f81e47f9bf",
  // )
  hash_out_ref_salt(out_ref_1, salt) == #"79b18aded9e04c72f38e5fa8c4b31a0f3dc83d47f9ad5cdc2eed3f22f477247e"
}

pub fn hash_out_refs_head_salt_sort_asc(
  out_refs: List<OutputReference>,
  salt: ByteArray,
) -> Hash<Blake2b_256, ByteArray> {
  when list.head(sort_asc_out_refs(out_refs)) is {
    Some(i) -> hash_out_ref_salt(i, salt)
    None -> fail @"not found input"
  }
}

test succ_hash_out_refs_head_salt_sort_asc() {
  let salt = #"060f4c8b63d168305c5b020708cac4e7befe6063f83f68255cb9c207860c4410"
  let out_ref_1 =
    OutputReference {
      transaction_id: TransactionId { hash: "lastTxn" },
      output_index: 1,
    }
  let out_ref_2 =
    OutputReference {
      transaction_id: TransactionId {
        hash: #"2b405c773982c6cddf1d8b8a80769a84851f3ce21febbb227777b3ba43be14f1",
      },
      output_index: 0,
    }
  let out_ref_3 =
    OutputReference {
      transaction_id: TransactionId { hash: "beg" },
      output_index: 1,
    }
  let out_ref_4 =
    OutputReference {
      transaction_id: TransactionId { hash: "lastTxn" },
      output_index: 3,
    }
  let out_ref_5 =
    OutputReference {
      transaction_id: TransactionId { hash: "beg" },
      output_index: 3,
    }
  hash_out_refs_head_salt_sort_asc(
    [out_ref_1, out_ref_2, out_ref_3, out_ref_4, out_ref_5],
    salt,
  ) == #"4ef8bc43b96a4d43955531b5db19e29d79c6aa205b11c64d686afe2e10289331"
}
