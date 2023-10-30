use aiken/dict.{Dict}
use aiken/hash.{Blake2b_224, Blake2b_256, Hash}
use aiken/transaction/credential.{VerificationKey}

pub type PublicKeyHash =
  Hash<Blake2b_224, VerificationKey>

pub type Datums =
  Dict<Hash<Blake2b_256, Data>, Data>

pub type POSIXTime =
  Int

pub type SlotConfigNetwork {
  zero_time: POSIXTime,
  zero_slot: Int,
  slot_length: Int,
}
