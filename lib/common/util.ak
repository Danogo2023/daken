use aiken/bytearray
use aiken/dict
use aiken/list
use aiken/transaction.{
  Datum, DatumHash, InlineDatum, Input, NoDatum, ScriptContext, Spend,
  Transaction,
}
use aiken/transaction/credential.{
  Address, ScriptCredential, VerificationKeyCredential,
}
use aiken/transaction/value.{PolicyId}
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

pub fn get_this_scripts_address(ctx: ScriptContext) -> Address {
  let input = get_spending_input(ctx)
  input.output.address
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

pub fn must_be_signed_by_key(
  pkhs: List<PublicKeyHash>,
  k: PublicKeyHash,
) -> Bool {
  list.has(pkhs, k)
}

pub fn must_be_signed_by(pkhs: List<PublicKeyHash>, a: Address) -> Bool {
  list.has(
    pkhs,
    when a.payment_credential is {
      VerificationKeyCredential(v) -> v
      ScriptCredential(_) -> fail @"Invalid PublicKeyHash"
    },
  )
}

pub fn get_number_from_hex_string(numstr: ByteArray) -> Int {
  bytearray.foldl(numstr, 0, fn(byte, acc) -> Int { acc * 0x100 + byte })
}

test convert_hex_string_to_int() {
  get_number_from_hex_string(#"887949ab") == 0x887949ab && //
  get_number_from_hex_string(#"") == 0 && //
  get_number_from_hex_string(#"00") == 0
}

/// Convert a integer `n` into some base `q`. This method
/// should scale with any integer and any logical base.
///
/// ```aiken
/// maths.base_q(123, 7)
/// ```
pub fn base_q(n: Int, q: Int) -> List<Int> {
  do_base_q(n, q, [])
}

fn do_base_q(number: Int, base: Int, holder: List<Int>) -> List<Int> {
  // if the number or base is zero return the holder list
  if number == 0 || base == 0 {
    holder
  } else {
    do_base_q(number / base, base, list.push(holder, number % base))
  }
}

pub fn from_int(num: Int, length: Int) -> ByteArray {
  let base_256 = base_q(num, 256)
  let result =
    list.foldr(base_256, #"", fn(n, total) { bytearray.push(total, n) })
  push_by_length(result, length)
}

fn push_by_length(self, length) -> ByteArray {
  if bytearray.length(self) < length {
    push_by_length(bytearray.push(self, 0), length)
  } else {
    self
  }
}

test from_int_1() {
  from_int(23, 2) == #"0017"
}

test from_int_2() {
  from_int(265, 2) == #"0109"
}

pub fn find_while(
  self: List<a>,
  zero: result,
  with: fn(a, result) -> (Bool, result),
) -> result {
  when self is {
    [] -> zero
    [x, ..xs] -> {
      let (break, r) = with(x, zero)
      if break {
        r
      } else {
        find_while(xs, r, with)
      }
    }
  }
}

pub fn is_burned_nft(tx: Transaction, policy_id: PolicyId, nft_name: ByteArray) {
  (
    tx.mint
      |> value.from_minted_value
      |> value.quantity_of(policy_id, nft_name)
  ) == -1
}
