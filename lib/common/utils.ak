use aiken/dict
use aiken/list
use aiken/transaction.{
  Datum, DatumHash, InlineDatum, Input, NoDatum, ScriptContext, Spend,
}
use aiken/transaction/credential.{
  Address, ScriptCredential, VerificationKeyCredential,
}
use common/types.{Datums, POSIXTime, PublicKeyHash, SlotConfigNetwork}

pub fn get_spending_input(ctx: ScriptContext) -> Input {
  expect Spend(output_reference) = ctx.purpose
  expect Some(input) =
    list.find(
      ctx.transaction.inputs,
      fn(i) { i.output_reference == output_reference },
    )
  input
}

pub fn get_data(datums: Datums, datum: Datum) -> Option<Data> {
  when datum is {
    NoDatum -> None
    DatumHash(h) -> dict.get(datums, h)
    InlineDatum(d) -> Some(d)
  }
}

pub fn slot_to_begin_posix_time(
  slot: Int,
  slot_config: SlotConfigNetwork,
) -> POSIXTime {
  slot_config.zero_time + ( slot - slot_config.zero_slot ) * slot_config.slot_length
}

pub fn posix_time_to_enclosing_slot(
  posix_time: POSIXTime,
  slot_config: SlotConfigNetwork,
) -> Int {
  ( posix_time - slot_config.zero_time ) / slot_config.slot_length + slot_config.zero_slot
}

pub fn get_payment_key(a: Address) -> ByteArray {
  when a.payment_credential is {
    VerificationKeyCredential(v) -> v
    ScriptCredential(s) -> s
  }
}

pub fn must_be_signed_by(pkhs: List<PublicKeyHash>, a: Address) -> Bool {
  list.has(pkhs, get_payment_key(a))
}
