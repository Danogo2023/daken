use aiken/dict
use aiken/list
use aiken/transaction.{InlineDatum, Transaction}
use aiken/transaction/credential.{Address, ScriptCredential}
use aiken/transaction/value.{PolicyId}
use club/constants.{operator_nft_prefix}
use club/danogo_feed/constants.{gov_token_name} as danogo_feed_constants
use club/danogo_feed/datum_types.{ProtocolParams}

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
               token_name == operator_nft_prefix
             },
           )
    },
  )
}

/// Must return protocol params from governance UTXO ref
/// can be used in any transaction that require protocol params to validate
/// e.g.: create club needs to validate SM addresses, ...
pub fn get_protocol_params(
  gov_policy_id: PolicyId,
  txn: Transaction,
) -> ProtocolParams {
  expect [gov_utxo] =
    list.filter(
      txn.reference_inputs,
      fn(ref) {
        ref.output.value
          |> value.tokens(gov_policy_id)
          |> dict.to_list()
          |> list.any(
               fn(token) {
                 let (token_name, _qty) = token
                 token_name == gov_token_name
               },
             )
      },
    )
  expect protocol_params: ProtocolParams =
    when gov_utxo.output.datum is {
      InlineDatum(d) -> d
      _ -> fail @"Not found InlineDatum"
    }
  protocol_params
}

pub fn get_deposit_pool_address(protocol_params: ProtocolParams) -> Address {
  Address {
    payment_credential: ScriptCredential(protocol_params.deposit_skh),
    stake_credential: Some(protocol_params.default_stake_key),
  }
}

pub fn get_deposit_state_address(protocol_params: ProtocolParams) -> Address {
  Address {
    payment_credential: ScriptCredential(protocol_params.deposit_state_skh),
    stake_credential: Some(protocol_params.default_stake_key),
  }
}
