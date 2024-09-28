use aiken/crypto
use aiken/primitive/bytearray
use cardano/transaction.{OutputReference}
use daken/convert
use daken/types.{Blake2b224Hash, Blake2b256Hash}

pub fn blake2b_256(i: OutputReference) -> Blake2b256Hash {
  crypto.blake2b_256(
    i.transaction_id
      |> bytearray.concat(convert.int_to_digit(i.output_index)),
  )
}

test succ_blake2b_256() {
  let out_ref_1 =
    OutputReference {
      transaction_id: #"2b405c773982c6cddf1d8b8a80769a84851f3ce21febbb227777b3ba43be14f1",
      output_index: 0,
    }
  blake2b_256(out_ref_1) == #"060f4c8b63d168305c5b020708cac4e7befe6063f83f68255cb9c207860c4410"
}

pub fn blake2b_256_salt(i: OutputReference, salt: ByteArray) -> Blake2b256Hash {
  crypto.blake2b_256(
    i.transaction_id
      |> bytearray.concat(convert.int_to_digit(i.output_index))
      |> bytearray.concat(salt),
  )
}

test succ_blake2b_256_salt() {
  let salt = #"d53d658b5f7eac3f741389135662a2bf9f2475844141705a5c0514f81e47f9bf"
  let out_ref_1 =
    OutputReference {
      transaction_id: #"23850612667a59e236ceeea412440b446fa697f2b988eb05e070aaa18c8cad0f",
      output_index: 0,
    }
  // blake2b_256_salt(out_ref_1, salt) == crypto.blake2b_256(
  //   #"23850612667a59e236ceeea412440b446fa697f2b988eb05e070aaa18c8cad0f30d53d658b5f7eac3f741389135662a2bf9f2475844141705a5c0514f81e47f9bf",
  // )
  blake2b_256_salt(out_ref_1, salt) == #"79b18aded9e04c72f38e5fa8c4b31a0f3dc83d47f9ad5cdc2eed3f22f477247e"
}

pub fn blake2b_224(i: OutputReference) -> Blake2b224Hash {
  crypto.blake2b_224(
    i.transaction_id
      |> bytearray.concat(convert.int_to_digit(i.output_index)),
  )
}

test succ_blake2b_224() {
  let out_ref_1 =
    OutputReference {
      transaction_id: #"2b405c773982c6cddf1d8b8a80769a84851f3ce21febbb227777b3ba43be14f1",
      output_index: 0,
    }
  blake2b_224(out_ref_1) == #"678cbdecaf56ed9a528555ca1a31decdd4cc35d385956905b2eff9fc"
}

pub fn blake2b_224_salt(i: OutputReference, salt: ByteArray) -> Blake2b224Hash {
  crypto.blake2b_224(
    i.transaction_id
      |> bytearray.concat(convert.int_to_digit(i.output_index))
      |> bytearray.concat(salt),
  )
}

test succ_blake2b_224_salt() {
  let salt = #"d53d658b5f7eac3f741389135662a2bf9f2475844141705a5c0514f81e47f9bf"
  let out_ref_1 =
    OutputReference {
      transaction_id: #"23850612667a59e236ceeea412440b446fa697f2b988eb05e070aaa18c8cad0f",
      output_index: 0,
    }
  // blake2b_224_salt(out_ref_1, salt) == crypto.blake2b_224(
  //   #"23850612667a59e236ceeea412440b446fa697f2b988eb05e070aaa18c8cad0f30d53d658b5f7eac3f741389135662a2bf9f2475844141705a5c0514f81e47f9bf",
  // )
  blake2b_224_salt(out_ref_1, salt) == #"e81638c1b0c97886d890281b17ed84e2889033fdfa5b0ed828068a88"
}
