use aiken/transaction.{
  InlineDatum, Input, Output, OutputReference, TransactionId,
}
use aiken/transaction/credential.{Inline, ScriptCredential}
use aiken/transaction/value
use club/club_tokens
use club/danogo_feed/types.{ProtocolParams, base_protocol_params}
use club/deposit_state/types.{DepositStateDatum,
  base_deposit_state_datum} as dep_type
use club/general_state/types.{GeneralStateDatum,
  base_general_state_datum} as gen_types
use club/helpers.{RefInputDatum, get_tuple_ref_inputs}
use club/nav_state/types.{NavStateDatum, base_nav_state_datum} as nav_type
use club/trading_state/types.{TradingStateDatum,
  base_trading_state_datum} as trading_type
use club/vault_state/types.{VaultStateDatum, base_vault_state_datum} as vau_type
use club/withdraw_state/types.{WithdrawStateDatum,
  base_withdraw_state_datum} as wit_type

const club_policy_id = "club_policy_id"

pub fn test_out_ref() -> OutputReference {
  let out_ref =
    OutputReference {
      transaction_id: TransactionId { hash: #"acab" },
      output_index: 0,
    }
  out_ref
}

fn get_protocol_params() -> ProtocolParams {
  ProtocolParams {
    ..base_protocol_params(),
    general_state_skh: "general_state_skh",
    trading_state_skh: "trading_state_skh",
    nav_state_skh: "nav_state_skh",
    deposit_state_skh: "deposit_state_skh",
    withdraw_state_skh: "withdraw_state_skh",
    vault_state_skh: "vault_state_skh",
  }
}

fn correct_general_input() -> Input {
  Input {
    output_reference: test_out_ref(),
    output: Output {
      address: helpers.get_general_state_address(get_protocol_params()),
      value: value.from_asset(
        club_policy_id,
        club_tokens.get_general_nft_name(),
        1,
      ),
      datum: InlineDatum(
        GeneralStateDatum {
          ..base_general_state_datum(),
          club_policy_id: club_policy_id,
        },
      ),
      reference_script: Some(club_policy_id),
    },
  }
}

fn correct_trading_input() -> Input {
  Input {
    output_reference: test_out_ref(),
    output: Output {
      address: helpers.get_trading_state_address(get_protocol_params()),
      value: value.from_asset(
        club_policy_id,
        club_tokens.get_trading_nft_name(),
        1,
      ),
      datum: InlineDatum(
        TradingStateDatum {
          ..base_trading_state_datum(),
          club_policy_id: club_policy_id,
        },
      ),
      reference_script: None,
    },
  }
}

fn correct_nav_input() -> Input {
  Input {
    output_reference: test_out_ref(),
    output: Output {
      address: helpers.get_nav_state_address(get_protocol_params()),
      value: value.from_asset(club_policy_id, club_tokens.get_nav_nft_name(), 1),
      datum: InlineDatum(
        NavStateDatum {
          ..base_nav_state_datum(),
          club_policy_id: club_policy_id,
        },
      ),
      reference_script: None,
    },
  }
}

fn correct_deposit_input() -> Input {
  Input {
    output_reference: test_out_ref(),
    output: Output {
      address: helpers.get_deposit_state_address(get_protocol_params()),
      value: value.from_asset(
        club_policy_id,
        club_tokens.get_deposit_state_nft_name(),
        1,
      ),
      datum: InlineDatum(
        DepositStateDatum {
          ..base_deposit_state_datum(),
          club_policy_id: club_policy_id,
        },
      ),
      reference_script: None,
    },
  }
}

fn correct_withdraw_input() -> Input {
  Input {
    output_reference: test_out_ref(),
    output: Output {
      address: helpers.get_withdraw_state_address(get_protocol_params()),
      value: value.from_asset(
        club_policy_id,
        club_tokens.get_withdraw_state_nft_name(),
        1,
      ),
      datum: InlineDatum(
        WithdrawStateDatum {
          ..base_withdraw_state_datum(),
          club_policy_id: club_policy_id,
        },
      ),
      reference_script: None,
    },
  }
}

fn correct_vault_input() -> Input {
  Input {
    output_reference: test_out_ref(),
    output: Output {
      address: helpers.get_vault_state_address(
        get_protocol_params(),
        Inline(ScriptCredential("stake")),
      ),
      value: value.from_asset(
        club_policy_id,
        club_tokens.get_vault_state_token_name(),
        1,
      ),
      datum: InlineDatum(
        VaultStateDatum {
          ..base_vault_state_datum(),
          club_policy_id: club_policy_id,
        },
      ),
      reference_script: None,
    },
  }
}

test success_get_tuple_ref_inputs() {
  get_tuple_ref_inputs(
    club_policy_id,
    get_protocol_params(),
    [
      correct_general_input(),
      correct_trading_input(),
      correct_nav_input(),
      correct_deposit_input(),
      correct_withdraw_input(),
      correct_vault_input(),
      correct_vault_input(),
    ],
  ) == RefInputDatum {
    general_state: Some(
      GeneralStateDatum {
        ..base_general_state_datum(),
        club_policy_id: club_policy_id,
      },
    ),
    trading_state: Some(
      TradingStateDatum {
        ..base_trading_state_datum(),
        club_policy_id: club_policy_id,
      },
    ),
    nav_state: Some(
      NavStateDatum { ..base_nav_state_datum(), club_policy_id: club_policy_id },
    ),
    deposit_state: Some(
      DepositStateDatum {
        ..base_deposit_state_datum(),
        club_policy_id: club_policy_id,
      },
    ),
    withdraw_state: Some(
      WithdrawStateDatum {
        ..base_withdraw_state_datum(),
        club_policy_id: club_policy_id,
      },
    ),
    vault_state_club_policy_id: club_policy_id,
    vault_state: [
      (
        test_out_ref(),
        VaultStateDatum {
          ..base_vault_state_datum(),
          club_policy_id: club_policy_id,
        },
      ),
      (
        test_out_ref(),
        VaultStateDatum {
          ..base_vault_state_datum(),
          club_policy_id: club_policy_id,
        },
      ),
    ],
  }
}

test fail_get_tuple_ref_inputs_1() fail {
  get_tuple_ref_inputs(
    club_policy_id,
    get_protocol_params(),
    [correct_general_input(), correct_general_input()],
  ) == RefInputDatum {
    general_state: None,
    trading_state: None,
    nav_state: None,
    deposit_state: None,
    withdraw_state: None,
    vault_state_club_policy_id: "",
    vault_state: [],
  }
}

test fail_get_tuple_ref_inputs_2() fail {
  get_tuple_ref_inputs(
    club_policy_id,
    get_protocol_params(),
    [
      correct_vault_input(),
      Input {
        output_reference: test_out_ref(),
        output: Output {
          address: helpers.get_vault_state_address(
            get_protocol_params(),
            Inline(ScriptCredential("stake")),
          ),
          value: value.from_asset(
            "different policy",
            club_tokens.get_vault_state_token_name(),
            1,
          ),
          datum: InlineDatum(
            VaultStateDatum {
              ..base_vault_state_datum(),
              club_policy_id: "different policy",
            },
          ),
          reference_script: None,
        },
      },
    ],
  ) == RefInputDatum {
    general_state: None,
    trading_state: None,
    nav_state: None,
    deposit_state: None,
    withdraw_state: None,
    vault_state_club_policy_id: "",
    vault_state: [],
  }
}

test fail_get_tuple_ref_inputs_3() fail {
  get_tuple_ref_inputs(
    "different policy",
    get_protocol_params(),
    [correct_general_input()],
  ) == RefInputDatum {
    general_state: None,
    trading_state: None,
    nav_state: None,
    deposit_state: None,
    withdraw_state: None,
    vault_state_club_policy_id: "",
    vault_state: [],
  }
}
