use aiken/dict
use aiken/list
use aiken/transaction.{Transaction}
use aiken/transaction/value.{PolicyId}
use club/club_tokens.{OperatorNft, find_club_token_type_from_name}
use club/danogo_feed/datum_types.{ProtocolParams}
use club/danogo_feed/tokens.{GovernanceToken, find_feed_token_type_from_name}
use common/util.{get_data}

/// Check if Operator token is presented in transaction inputs
/// can be used in any transaction that requires Operator token to be valid
/// e.g.: update general utxo, update trading utxo...
pub fn exists_op_token(club_policy_id: PolicyId, txn: Transaction) -> Bool {
  list.any(
    txn.inputs,
    fn(in) {
      in.output.value
        |> value.tokens(club_policy_id)
        |> dict.to_list()
        |> list.any(
             fn(token) {
               let (token_name, _qty) = token
               when find_club_token_type_from_name(token_name) is {
                 OperatorNft -> True
                 _ -> False
               }
             },
           )
    },
  )
}

/// Must return protocol params from governance UTXO ref
/// can be used in any transaction that require protocol params to validate
/// e.g.: create club needs to validate SM addresses, ...
pub fn get_protocol_params(
  governance_policy_id: PolicyId,
  txn: Transaction,
) -> ProtocolParams {
  expect [governance_utxo] =
    list.filter(
      txn.reference_inputs,
      fn(ref) {
        ref.output.value
          |> value.tokens(governance_policy_id)
          |> dict.to_list()
          |> list.any(
               fn(token) {
                 let (token_name, _qty) = token
                 when find_feed_token_type_from_name(token_name) is {
                   GovernanceToken -> True
                   _ -> False
                 }
               },
             )
      },
    )
  expect Some(datum) = get_data(txn.datums, governance_utxo.output.datum)
  expect protocol_params: ProtocolParams = datum
  protocol_params
}
