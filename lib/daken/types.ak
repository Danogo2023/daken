use aiken/collection/dict.{Dict}
use aiken/crypto.{
  Blake2b_224, Blake2b_256, DataHash, Hash, ScriptHash, VerificationKeyHash,
}
use cardano/assets.{AssetName, PolicyId}
use cardano/transaction.{Redeemer, ScriptPurpose}

pub type Redeemers =
  Pairs<ScriptPurpose, Redeemer>

pub type PublicKeyHash =
  VerificationKeyHash

pub type Blake2b224Hash =
  Hash<Blake2b_224, ByteArray>

pub type Blake2b256Hash =
  Hash<Blake2b_256, ByteArray>

pub type TupleAsset =
  (PolicyId, AssetName)

pub type ScriptKeyHash =
  ScriptHash

pub type Datums =
  Dict<DataHash, Data>

pub type AssetUnit =
  String

pub type Result<a, b> {
  OK(a)
  Error(b)
}

pub type PosixTime =
  Int

pub type Basis =
  Int

pub type Asset {
  policy_id: PolicyId,
  asset_name: AssetName,
}
