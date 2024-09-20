use aiken/collection/dict.{Dict}
use aiken/crypto.{Blake2b_224, Blake2b_256, Hash, Script, VerificationKey}

pub type PublicKeyHash =
  Hash<Blake2b_224, VerificationKey>

pub type ScriptKeyHash =
  Hash<Blake2b_224, Script>

pub type Datums =
  Dict<Hash<Blake2b_256, Data>, Data>

pub type Lovelace =
  Int

pub type AssetUnit =
  String

pub type Result<a, b> {
  OK(a)
  Error(b)
}

pub type PosixTime =
  Int
