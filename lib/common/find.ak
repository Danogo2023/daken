use aiken/pairs
use aiken/transaction.{OutputReference, Redeemer, ScriptPurpose, Spend}

pub fn redeemer_by_ref(
  redeemers: Pairs<ScriptPurpose, Redeemer>,
  outref: OutputReference,
) -> Data {
  expect [redeemer] = pairs.get_all(redeemers, Spend(outref))
  redeemer
}
