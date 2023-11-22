use aiken/transaction.{
  Datum, InlineDatum, Input, NoDatum, Output, OutputReference, Transaction,
  TransactionId,
}
use aiken/transaction/credential.{from_verification_key}
use aiken/transaction/value.{Value}
use club/constants.{operator_nft_prefix} as club_constant
use club/danogo_feed/constants.{governance_token_name}
use club/danogo_feed/datum_types.{base_price_feed_datum, base_protocol_params}
use club/helpers.{exists_op_token, get_protocol_params}

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

test test_exist_op_nft_1() {
  let txn =
    Transaction {
      ..transaction.placeholder(),
      inputs: [get_input_w_value(value.zero())],
    }

  !exists_op_token(club_policy_id, txn)
}

test test_exist_op_nft_2() {
  let txn =
    Transaction {
      ..transaction.placeholder(),
      inputs: [
        get_input_w_value(value.zero()),
        get_input_w_value(value.from_asset("some policy", "some name", 1)),
        get_input_w_value(value.from_asset("some policy", "other name", 10)),
        get_input_w_value(
          value.from_asset(club_policy_id, operator_nft_prefix, 1)
            |> value.add("policy", "name", 5),
        ),
      ],
    }

  exists_op_token(club_policy_id, txn)
}

test test_exist_op_nft_3() {
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
const governance_policy_id = "governance_policy_id"

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

test test_get_protocol_params_1() fail {
  let txn =
    Transaction {
      ..transaction.placeholder(),
      reference_inputs: [
        get_input_w_value_datum(
          value.from_asset(governance_policy_id, governance_token_name, 1),
          NoDatum,
        ),
      ],
    }

  get_protocol_params(governance_policy_id, txn) == base_protocol_params()
}

test test_get_protocol_params_2() {
  let txn =
    Transaction {
      ..transaction.placeholder(),
      reference_inputs: [
        get_input_w_value_datum(
          value.from_asset(governance_policy_id, governance_token_name, 1),
          InlineDatum(base_protocol_params()),
        ),
      ],
    }

  get_protocol_params(governance_policy_id, txn) == base_protocol_params()
}

test test_get_protocol_params_3() fail {
  let txn =
    Transaction {
      ..transaction.placeholder(),
      reference_inputs: [
        get_input_w_value_datum(
          value.from_asset(governance_policy_id, governance_token_name, 1),
          InlineDatum(base_protocol_params()),
        ),
        get_input_w_value_datum(
          value.from_asset(governance_policy_id, governance_token_name, 1),
          InlineDatum(base_protocol_params()),
        ),
      ],
    }

  get_protocol_params(governance_policy_id, txn) == base_protocol_params()
}

test test_get_protocol_params_4() fail {
  let txn =
    Transaction {
      ..transaction.placeholder(),
      reference_inputs: [
        get_input_w_value_datum(
          value.from_asset(governance_policy_id, governance_token_name, 1),
          InlineDatum(base_price_feed_datum()),
        ),
      ],
    }

  get_protocol_params(governance_policy_id, txn) == base_protocol_params()
}
