use aiken/bytearray
use aiken/dict
use aiken/list
use aiken/transaction.{
  Datum, DatumHash, InlineDatum, Input, NoDatum, ScriptContext, Spend,
}
use aiken/transaction/credential.{
  Address, ScriptCredential, VerificationKeyCredential,
}
use common/types.{Datums, PublicKeyHash}

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

pub fn get_payment_key(a: Address) -> ByteArray {
  when a.payment_credential is {
    VerificationKeyCredential(v) -> v
    ScriptCredential(s) -> s
  }
}

pub fn must_be_signed_by(pkhs: List<PublicKeyHash>, a: Address) -> Bool {
  list.has(pkhs, get_payment_key(a))
}

pub fn get_number_from_hex_string(numstr: ByteArray) -> Int {
  bytearray.foldl(numstr, 0, fn(byte, acc) -> Int { acc * 0x100 + byte })
}

test convert_hex_string_to_int() {
  get_number_from_hex_string(#"887949ab") == 0x887949ab && //
  get_number_from_hex_string(#"") == 0 && //
  get_number_from_hex_string(#"00") == 0
}
