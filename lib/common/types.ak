use aiken/dict.{Dict}
use aiken/hash.{Blake2b_224, Blake2b_256, Hash}
use aiken/transaction/credential.{Script, VerificationKey}

pub type PublicKeyHash =
  Hash<Blake2b_224, VerificationKey>

pub type ScriptKeyHash =
  Hash<Blake2b_224, Script>

pub type Datums =
  Dict<Hash<Blake2b_256, Data>, Data>

pub type Lovelace =
  Int

pub type AssetUnit =
  ByteArray

pub type Result<a, b> {
  OK(a)
  Error(b)
}