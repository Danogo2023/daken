use aiken/crypto
use aiken/primitive/bytearray
use cardano/address
use cardano/assets
use cardano/transaction.{Input, NoDatum, Output, OutputReference}
use daken/convert
use daken/types.{Blake2b224Hash, Blake2b256Hash}

pub fn blake2b_256(
  Input {
    output_reference: OutputReference { transaction_id, output_index },
    ..
  }: Input,
) -> Blake2b256Hash {
  convert.int_to_digit(output_index)
    |> bytearray.concat(transaction_id, _)
    |> crypto.blake2b_256
}

test succ_blake2b_256() {
  let utxo1 =
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
  // blake2b_256(utxo1) == crypto.blake2b_256(
  //   bytearray.concat(
  //     #"2b405c773982c6cddf1d8b8a80769a84851f3ce21febbb227777b3ba43be14f1",
  //     convert.int_to_digit(0),
  //   ),
  // )
  blake2b_256(utxo1) == #"060f4c8b63d168305c5b020708cac4e7befe6063f83f68255cb9c207860c4410"
}

pub fn blake2b_256_salt(
  Input {
    output_reference: OutputReference { transaction_id, output_index },
    ..
  }: Input,
  salt: ByteArray,
) -> Blake2b256Hash {
  convert.int_to_digit(output_index)
    |> bytearray.concat(transaction_id, _)
    |> bytearray.concat(salt)
    |> crypto.blake2b_256
}

test succ_blake2b_256_salt() {
  let salt = #"d53d658b5f7eac3f741389135662a2bf9f2475844141705a5c0514f81e47f9bf"
  let utxo1 =
    Input {
      output_reference: OutputReference {
        transaction_id: #"23850612667a59e236ceeea412440b446fa697f2b988eb05e070aaa18c8cad0f",
        output_index: 0,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  // blake2b_256_salt(utxo1, salt) == crypto.blake2b_256(
  //   #"23850612667a59e236ceeea412440b446fa697f2b988eb05e070aaa18c8cad0f30d53d658b5f7eac3f741389135662a2bf9f2475844141705a5c0514f81e47f9bf",
  // )
  blake2b_256_salt(utxo1, salt) == #"79b18aded9e04c72f38e5fa8c4b31a0f3dc83d47f9ad5cdc2eed3f22f477247e"
}

pub fn blake2b_224(
  Input {
    output_reference: OutputReference { transaction_id, output_index },
    ..
  }: Input,
) -> Blake2b224Hash {
  convert.int_to_digit(output_index)
    |> bytearray.concat(transaction_id, _)
    |> crypto.blake2b_224
}

test succ_blake2b_224() {
  let utxo1 =
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
  // blake2b_224(utxo1) == crypto.blake2b_224(
  //   bytearray.concat(
  //     #"2b405c773982c6cddf1d8b8a80769a84851f3ce21febbb227777b3ba43be14f1",
  //     convert.int_to_digit(0),
  //   ),
  // )
  blake2b_224(utxo1) == #"678cbdecaf56ed9a528555ca1a31decdd4cc35d385956905b2eff9fc"
}

pub fn blake2b_224_salt(
  Input {
    output_reference: OutputReference { transaction_id, output_index },
    ..
  }: Input,
  salt: ByteArray,
) -> Blake2b224Hash {
  convert.int_to_digit(output_index)
    |> bytearray.concat(transaction_id, _)
    |> bytearray.concat(salt)
    |> crypto.blake2b_224
}

test succ_blake2b_224_salt() {
  let salt = #"d53d658b5f7eac3f741389135662a2bf9f2475844141705a5c0514f81e47f9bf"
  let utxo1 =
    Input {
      output_reference: OutputReference {
        transaction_id: #"23850612667a59e236ceeea412440b446fa697f2b988eb05e070aaa18c8cad0f",
        output_index: 0,
      },
      output: Output {
        address: address.from_script(#""),
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }
  // blake2b_224_salt(utxo1, salt) == crypto.blake2b_224(
  //   #"23850612667a59e236ceeea412440b446fa697f2b988eb05e070aaa18c8cad0f30d53d658b5f7eac3f741389135662a2bf9f2475844141705a5c0514f81e47f9bf",
  // )
  blake2b_224_salt(utxo1, salt) == #"e81638c1b0c97886d890281b17ed84e2889033fdfa5b0ed828068a88"
}
