use aiken/transaction.{
  Datum, InlineDatum, Input, NoDatum, Output, OutputReference, Transaction,
  TransactionId,
}
use aiken/transaction/credential.{
  Address, Inline, ScriptCredential, VerificationKeyCredential,
  from_verification_key,
}
use aiken/transaction/value.{Value}
use club/club_tokens.{get_operator_nft_name}
use club/danogo_feed/constants.{gov_token_name}
use club/danogo_feed/types.{
  ProtocolParams, base_price_feed_datum, base_protocol_params,
}
use club/helpers.{
  exists_op_token, get_deposit_pool_address, get_deposit_state_address,
  get_protocol_params,
}

// ======================= OP NFT ==========================
const club_policy_id = "club_policy_id"

fn get_input_w_value(v: Value) -> Input {
  Input {
    output_reference: OutputReference {
      transaction_id: TransactionId { hash: "" },
      output_index: 0,
    },
    output: Output {
      address: from_verification_key("vk"),
      value: v,
      datum: NoDatum,
      reference_script: None,
    },
  }
}

test exist_op_nft_1() {
  let txn =
    Transaction {
      ..transaction.placeholder(),
      inputs: [get_input_w_value(value.zero())],
    }

  !exists_op_token(club_policy_id, txn)
}

test exist_op_nft_2() {
  let txn =
    Transaction {
      ..transaction.placeholder(),
      inputs: [
        get_input_w_value(value.zero()),
        get_input_w_value(value.from_asset("some policy", "some name", 1)),
        get_input_w_value(value.from_asset("some policy", "other name", 10)),
        get_input_w_value(
          value.from_asset(club_policy_id, get_operator_nft_name(), 1)
            |> value.add("policy", "name", 5),
        ),
      ],
    }

  exists_op_token(club_policy_id, txn)
}

test exist_op_nft_3() {
  let txn =
    Transaction {
      ..transaction.placeholder(),
      inputs: [
        get_input_w_value(value.zero()),
        get_input_w_value(value.from_asset("some policy", "some name", 1)),
        get_input_w_value(value.from_asset("some policy", "other name", 10)),
        get_input_w_value(
          value.from_asset(club_policy_id, "wrong name", 1)
            |> value.add("policy", "name", 5),
        ),
      ],
    }

  !exists_op_token(club_policy_id, txn)
}

// ======================= Protocol params ==========================
const gov_policy_id = "gov_policy_id"

fn get_input_w_value_datum(v: Value, d: Datum) -> Input {
  Input {
    output_reference: OutputReference {
      transaction_id: TransactionId { hash: "" },
      output_index: 0,
    },
    output: Output {
      address: from_verification_key("vk"),
      value: v,
      datum: d,
      reference_script: None,
    },
  }
}

test get_protocol_params_fail_datum_not_found() fail {
  let txn =
    Transaction {
      ..transaction.placeholder(),
      reference_inputs: [
        get_input_w_value_datum(
          value.from_asset(gov_policy_id, gov_token_name, 1),
          NoDatum,
        ),
      ],
    }

  get_protocol_params(gov_policy_id, txn.reference_inputs) == base_protocol_params()
}

test get_protocol_params_succ_1() {
  let txn =
    Transaction {
      ..transaction.placeholder(),
      reference_inputs: [
        get_input_w_value_datum(
          value.from_asset(gov_policy_id, gov_token_name, 1),
          InlineDatum(base_protocol_params()),
        ),
      ],
    }

  get_protocol_params(gov_policy_id, txn.reference_inputs) == base_protocol_params()
}

test get_protocol_params_succ_2() {
  let txn =
    Transaction {
      ..transaction.placeholder(),
      reference_inputs: [
        get_input_w_value_datum(
          value.from_asset(gov_policy_id, gov_token_name, 1),
          InlineDatum(base_protocol_params()),
        ),
        get_input_w_value_datum(
          value.from_asset(gov_policy_id, gov_token_name, 1),
          InlineDatum(base_protocol_params()),
        ),
      ],
    }

  get_protocol_params(gov_policy_id, txn.reference_inputs) == base_protocol_params()
}

test get_protocol_params_fail_datum_invalid_expect() fail {
  let txn =
    Transaction {
      ..transaction.placeholder(),
      reference_inputs: [
        get_input_w_value_datum(
          value.from_asset(gov_policy_id, gov_token_name, 1),
          InlineDatum(base_price_feed_datum()),
        ),
      ],
    }

  get_protocol_params(gov_policy_id, txn.reference_inputs) == base_protocol_params()
}

test get_deposit_state_addr_1() {
  let deposit_state_skh =
    #"87d5500c17ebf50604f4f13a32307b4f2a49db57774b6debc310d492"
  let default_stake_key =
    #"67043b1e182b0f30a2350d12e1ce69c843f4131c86057d376ae58baa"
  let stake_credential = Inline(VerificationKeyCredential(default_stake_key))
  let protocol_params =
    ProtocolParams {
      ..base_protocol_params(),
      deposit_state_skh: #"87d5500c17ebf50604f4f13a32307b4f2a49db57774b6debc310d492",
      default_stake_key: stake_credential,
    }
  get_deposit_state_address(protocol_params) == Address {
    payment_credential: ScriptCredential(deposit_state_skh),
    stake_credential: Some(stake_credential),
  }
}

test get_deposit_pool_addr_1() {
  let deposit_pool_skh =
    #"87d5500c17ebf50604f4f13a32307b4f2a49db57774b6debc310d492"
  let default_stake_key =
    #"67043b1e182b0f30a2350d12e1ce69c843f4131c86057d376ae58baa"
  let stake_credential = Inline(VerificationKeyCredential(default_stake_key))
  let protocol_params =
    ProtocolParams {
      ..base_protocol_params(),
      deposit_pool_skh: #"87d5500c17ebf50604f4f13a32307b4f2a49db57774b6debc310d492",
      default_stake_key: stake_credential,
    }
  get_deposit_pool_address(protocol_params) == Address {
    payment_credential: ScriptCredential(deposit_pool_skh),
    stake_credential: Some(stake_credential),
  }
}
