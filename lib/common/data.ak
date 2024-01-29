use aiken/transaction.{InlineDatum, Input, Output}

pub fn input_datum(possible_input: Input) -> Data {
  expect InlineDatum(inbound_datum) = possible_input.output.datum
  inbound_datum
}

pub fn output_datum(possible_output: Output) -> Data {
  expect InlineDatum(outbound_datum) = possible_output.datum
  outbound_datum
}
