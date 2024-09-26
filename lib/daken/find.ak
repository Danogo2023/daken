use aiken/collection/list
use aiken/collection/pairs
use cardano/transaction.{Input, OutputReference, Spend}
use daken/types.{Redeemers}

pub fn redeemer_by_ref(redeemers: Redeemers, outref: OutputReference) -> Data {
  expect [redeemer] = pairs.get_all(redeemers, Spend(outref))
  redeemer
}

pub fn inputs_contain_outref(
  inputs: List<Input>,
  outref: OutputReference,
) -> Bool {
  list.any(inputs, fn(i) -> Bool { i.output_reference == outref })
}
