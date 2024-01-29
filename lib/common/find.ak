use aiken/dict.{Dict}
use aiken/transaction.{OutputReference, Redeemer, ScriptPurpose, Spend}

pub fn redeemer_by_ref(
  redeemers: Dict<ScriptPurpose, Redeemer>,
  outref: OutputReference,
) -> Data {
  expect Some(redeemer) = dict.get(redeemers, Spend(outref))
  redeemer
}
