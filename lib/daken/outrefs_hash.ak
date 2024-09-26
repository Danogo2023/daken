use aiken/collection/list
use aiken/crypto
use aiken/primitive/bytearray
use cardano/transaction.{OutputReference}
use daken/convert
use daken/outref_hash
use daken/sort
use daken/types.{Blake2b224Hash, Blake2b256Hash}

pub fn blake2b_256(out_refs: List<OutputReference>) -> Blake2b256Hash {
  crypto.blake2b_256(
    list.foldl(
      out_refs,
      #"",
      fn(o: OutputReference, ret: ByteArray) -> ByteArray {
        o.transaction_id
          |> bytearray.concat(convert.int_to_digit(o.output_index))
          |> bytearray.concat(ret, _)
      },
    ),
  )
}

test succ_blake2b_256() {
  let out_ref_1 = OutputReference { transaction_id: "lastTxn", output_index: 0 }
  let out_ref_2 = OutputReference { transaction_id: "mid", output_index: 0 }
  let out_ref_3 = OutputReference { transaction_id: "beg", output_index: 0 }
  let out_ref_4 = OutputReference { transaction_id: "lastTxn", output_index: 3 }
  let out_ref_5 = OutputReference { transaction_id: "beg", output_index: 3 }
  blake2b_256([out_ref_1, out_ref_2, out_ref_3, out_ref_4, out_ref_5]) == #"0eb64f44615884988f7f32d7fab886172d8bac004ebf5c815410f8a87c5cd54d"
}

pub fn blake2b_256_sort_asc(out_refs: List<OutputReference>) -> Blake2b256Hash {
  blake2b_256(sort.out_refs_sort_asc(out_refs))
}

test succ_blake2b_256_sort_asc() {
  let out_ref_1 = OutputReference { transaction_id: "lastTxn", output_index: 0 }
  let out_ref_2 = OutputReference { transaction_id: "mid", output_index: 0 }
  let out_ref_3 = OutputReference { transaction_id: "beg", output_index: 0 }
  let out_ref_4 = OutputReference { transaction_id: "lastTxn", output_index: 3 }
  let out_ref_5 = OutputReference { transaction_id: "beg", output_index: 3 }
  blake2b_256_sort_asc([out_ref_1, out_ref_2, out_ref_3, out_ref_4, out_ref_5]) == #"7d162c7ea297a557904b98a0bf7282013f67b36c86120a41f2b8da2ea83af5b4"
}

pub fn blake2b_256_quicksort_asc(
  out_refs: List<OutputReference>,
) -> Blake2b256Hash {
  blake2b_256(sort.out_refs_quicksort_asc(out_refs))
}

test succ_blake2b_256_quicksort_asc() {
  let out_ref_1 = OutputReference { transaction_id: "lastTxn", output_index: 0 }
  let out_ref_2 = OutputReference { transaction_id: "mid", output_index: 0 }
  let out_ref_3 = OutputReference { transaction_id: "beg", output_index: 0 }
  let out_ref_4 = OutputReference { transaction_id: "lastTxn", output_index: 3 }
  let out_ref_5 = OutputReference { transaction_id: "beg", output_index: 3 }
  blake2b_256_quicksort_asc(
    [out_ref_1, out_ref_2, out_ref_3, out_ref_4, out_ref_5],
  ) == #"7d162c7ea297a557904b98a0bf7282013f67b36c86120a41f2b8da2ea83af5b4"
}

pub fn blake2b_256_head_sort_asc(
  out_refs: List<OutputReference>,
) -> Blake2b256Hash {
  when list.head(sort.out_refs_sort_asc(out_refs)) is {
    Some(i) -> outref_hash.blake2b_256(i)
    _ -> #""
  }
}

test succ_blake2b_256_head_sort_asc() {
  let out_ref_1 = OutputReference { transaction_id: "lastTxn", output_index: 1 }
  let out_ref_2 =
    OutputReference {
      transaction_id: #"2b405c773982c6cddf1d8b8a80769a84851f3ce21febbb227777b3ba43be14f1",
      output_index: 0,
    }
  let out_ref_3 = OutputReference { transaction_id: "beg", output_index: 1 }
  let out_ref_4 = OutputReference { transaction_id: "lastTxn", output_index: 3 }
  let out_ref_5 = OutputReference { transaction_id: "beg", output_index: 3 }
  blake2b_256_head_sort_asc(
    [out_ref_1, out_ref_2, out_ref_3, out_ref_4, out_ref_5],
  ) == #"060f4c8b63d168305c5b020708cac4e7befe6063f83f68255cb9c207860c4410"
}

pub fn blake2b_256_last_sort_asc(
  out_refs: List<OutputReference>,
) -> Blake2b256Hash {
  when list.last(sort.out_refs_sort_asc(out_refs)) is {
    Some(i) -> outref_hash.blake2b_256(i)
    _ -> #""
  }
}

test succ_blake2b_256_last_sort_asc() {
  let out_ref_1 = OutputReference { transaction_id: "lastTxn", output_index: 0 }
  let out_ref_2 = OutputReference { transaction_id: "mid", output_index: 2 }
  let out_ref_3 = OutputReference { transaction_id: "beg", output_index: 1 }
  let out_ref_4 = OutputReference { transaction_id: "lastTxn", output_index: 3 }
  let out_ref_5 = OutputReference { transaction_id: "beg", output_index: 3 }
  blake2b_256_last_sort_asc(
    [out_ref_1, out_ref_2, out_ref_3, out_ref_4, out_ref_5],
  ) == #"2d899c3cbad1a6b649d7381f38d30e41063eee0270675bc355f2a4f51ea91c46"
}

pub fn blake2b_256_salt_head_sort_asc(
  out_refs: List<OutputReference>,
  salt: ByteArray,
) -> Blake2b256Hash {
  when list.head(sort.out_refs_sort_asc(out_refs)) is {
    Some(i) -> outref_hash.blake2b_256_salt(i, salt)
    _ -> #""
  }
}

test succ_blake2b_256_salt_head_sort_asc() {
  let salt = #"060f4c8b63d168305c5b020708cac4e7befe6063f83f68255cb9c207860c4410"
  let out_ref_1 = OutputReference { transaction_id: "lastTxn", output_index: 1 }
  let out_ref_2 =
    OutputReference {
      transaction_id: #"2b405c773982c6cddf1d8b8a80769a84851f3ce21febbb227777b3ba43be14f1",
      output_index: 0,
    }
  let out_ref_3 = OutputReference { transaction_id: "beg", output_index: 1 }
  let out_ref_4 = OutputReference { transaction_id: "lastTxn", output_index: 3 }
  let out_ref_5 = OutputReference { transaction_id: "beg", output_index: 3 }
  blake2b_256_salt_head_sort_asc(
    [out_ref_1, out_ref_2, out_ref_3, out_ref_4, out_ref_5],
    salt,
  ) == #"4ef8bc43b96a4d43955531b5db19e29d79c6aa205b11c64d686afe2e10289331"
}

pub fn blake2b_224(out_refs: List<OutputReference>) -> Blake2b224Hash {
  crypto.blake2b_224(
    list.foldl(
      out_refs,
      #"",
      fn(o: OutputReference, ret: ByteArray) -> ByteArray {
        o.transaction_id
          |> bytearray.concat(convert.int_to_digit(o.output_index))
          |> bytearray.concat(ret, _)
      },
    ),
  )
}

test succ_blake2b_224() {
  let out_ref_1 = OutputReference { transaction_id: "lastTxn", output_index: 0 }
  let out_ref_2 = OutputReference { transaction_id: "mid", output_index: 0 }
  let out_ref_3 = OutputReference { transaction_id: "beg", output_index: 0 }
  let out_ref_4 = OutputReference { transaction_id: "lastTxn", output_index: 3 }
  let out_ref_5 = OutputReference { transaction_id: "beg", output_index: 3 }
  blake2b_224([out_ref_1, out_ref_2, out_ref_3, out_ref_4, out_ref_5]) == #"3a2193b236081057b9bdbf9300274efed0cec5d64036a7172662b72e"
}

pub fn blake2b_224_sort_asc(out_refs: List<OutputReference>) -> Blake2b224Hash {
  blake2b_224(sort.out_refs_sort_asc(out_refs))
}

test succ_blake2b_224_sort_asc() {
  let out_ref_1 = OutputReference { transaction_id: "lastTxn", output_index: 0 }
  let out_ref_2 = OutputReference { transaction_id: "mid", output_index: 0 }
  let out_ref_3 = OutputReference { transaction_id: "beg", output_index: 0 }
  let out_ref_4 = OutputReference { transaction_id: "lastTxn", output_index: 3 }
  let out_ref_5 = OutputReference { transaction_id: "beg", output_index: 3 }
  blake2b_224_sort_asc([out_ref_1, out_ref_2, out_ref_3, out_ref_4, out_ref_5]) == #"68f4e4777d5f1890d46595880c40907556457ed89f5edca42889f222"
}

pub fn blake2b_224_quicksort_asc(
  out_refs: List<OutputReference>,
) -> Blake2b224Hash {
  blake2b_224(sort.out_refs_quicksort_asc(out_refs))
}

test succ_blake2b_224_quicksort_asc() {
  let out_ref_1 = OutputReference { transaction_id: "lastTxn", output_index: 0 }
  let out_ref_2 = OutputReference { transaction_id: "mid", output_index: 0 }
  let out_ref_3 = OutputReference { transaction_id: "beg", output_index: 0 }
  let out_ref_4 = OutputReference { transaction_id: "lastTxn", output_index: 3 }
  let out_ref_5 = OutputReference { transaction_id: "beg", output_index: 3 }
  blake2b_224_quicksort_asc(
    [out_ref_1, out_ref_2, out_ref_3, out_ref_4, out_ref_5],
  ) == #"68f4e4777d5f1890d46595880c40907556457ed89f5edca42889f222"
}

pub fn blake2b_224_head_sort_asc(
  out_refs: List<OutputReference>,
) -> Blake2b224Hash {
  when list.head(sort.out_refs_sort_asc(out_refs)) is {
    Some(i) -> outref_hash.blake2b_224(i)
    _ -> #""
  }
}

test succ_blake2b_224_head_sort_asc() {
  let out_ref_1 = OutputReference { transaction_id: "lastTxn", output_index: 1 }
  let out_ref_2 =
    OutputReference {
      transaction_id: #"2b405c773982c6cddf1d8b8a80769a84851f3ce21febbb227777b3ba43be14f1",
      output_index: 0,
    }
  let out_ref_3 = OutputReference { transaction_id: "beg", output_index: 1 }
  let out_ref_4 = OutputReference { transaction_id: "lastTxn", output_index: 3 }
  let out_ref_5 = OutputReference { transaction_id: "beg", output_index: 3 }
  blake2b_224_head_sort_asc(
    [out_ref_1, out_ref_2, out_ref_3, out_ref_4, out_ref_5],
  ) == #"678cbdecaf56ed9a528555ca1a31decdd4cc35d385956905b2eff9fc"
}

pub fn blake2b_224_last_sort_asc(
  out_refs: List<OutputReference>,
) -> Blake2b224Hash {
  when list.last(sort.out_refs_sort_asc(out_refs)) is {
    Some(i) -> outref_hash.blake2b_224(i)
    _ -> #""
  }
}

test succ_blake2b_224_last_sort_asc() {
  let out_ref_1 = OutputReference { transaction_id: "lastTxn", output_index: 0 }
  let out_ref_2 = OutputReference { transaction_id: "mid", output_index: 2 }
  let out_ref_3 = OutputReference { transaction_id: "beg", output_index: 1 }
  let out_ref_4 = OutputReference { transaction_id: "lastTxn", output_index: 3 }
  let out_ref_5 = OutputReference { transaction_id: "beg", output_index: 3 }
  blake2b_224_last_sort_asc(
    [out_ref_1, out_ref_2, out_ref_3, out_ref_4, out_ref_5],
  ) == #"4ae75be874e9ef95c001bfd21c12ff29a7bd8186ff9fcb2313c566a0"
}

pub fn blake2b_224_salt_head_sort_asc(
  out_refs: List<OutputReference>,
  salt: ByteArray,
) -> Blake2b224Hash {
  when list.head(sort.out_refs_sort_asc(out_refs)) is {
    Some(i) -> outref_hash.blake2b_224_salt(i, salt)
    _ -> #""
  }
}
