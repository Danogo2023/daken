use aiken/bytearray
use aiken/dict.{Dict}
use aiken/list
use aiken/transaction.{Datum, Input, OutputReference, Transaction}
use aiken/transaction/credential.{
  Address, ScriptCredential, StakeCredential, VerificationKeyCredential,
}
use aiken/transaction/value.{PolicyId, Value}
use assist/data.{output_datum}
use club/club_tokens.{
  get_deposit_state_nft_name, get_general_nft_name, get_nav_nft_name,
  get_operator_nft_name, get_trading_nft_name, get_vault_state_token_name,
  get_withdraw_state_nft_name,
}
use club/danogo_feed/tokens.{get_gov_nft_name} as club_danogo_feed_tokens
use club/danogo_feed/types.{ProtocolParams}
use club/deposit_state/types.{DepositStateDatum} as club_deposit_state_types
use club/general_state/types.{GeneralStateDatum} as club_general_state_types
use club/nav_state/types.{NavStateDatum} as club_nav_state_types
use club/trading_state/types.{TradingStateDatum} as club_trading_state_types
use club/vault_state/types.{VaultStateDatum} as club_vault_state_types
use club/withdraw_state/types.{WithdrawStateDatum} as club_withdraw_state_types

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
               token_name == get_operator_nft_name()
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
  ref_inputs: List<Input>,
) -> ProtocolParams {
  when
    list.find(
      ref_inputs,
      fn(ref) {
        value.quantity_of(ref.output.value, gov_policy_id, get_gov_nft_name()) == 1
      },
    )
  is {
    None -> fail @"Not found governance utxo"
    Some(i) -> {
      expect protocol_params: ProtocolParams = output_datum(i.output)
      protocol_params
    }
  }
}

pub fn get_general_state_address(protocol_params: ProtocolParams) -> Address {
  Address {
    payment_credential: ScriptCredential(protocol_params.general_state_skh),
    stake_credential: Some(protocol_params.default_stake_key),
  }
}

pub fn get_trading_state_address(protocol_params: ProtocolParams) -> Address {
  Address {
    payment_credential: ScriptCredential(protocol_params.trading_state_skh),
    stake_credential: Some(protocol_params.default_stake_key),
  }
}

pub fn get_nav_state_address(protocol_params: ProtocolParams) -> Address {
  Address {
    payment_credential: ScriptCredential(protocol_params.nav_state_skh),
    stake_credential: Some(protocol_params.default_stake_key),
  }
}

pub fn get_deposit_state_address(protocol_params: ProtocolParams) -> Address {
  Address {
    payment_credential: ScriptCredential(protocol_params.deposit_state_skh),
    stake_credential: Some(protocol_params.default_stake_key),
  }
}

pub fn get_deposit_pool_address(protocol_params: ProtocolParams) -> Address {
  Address {
    payment_credential: ScriptCredential(protocol_params.deposit_pool_skh),
    stake_credential: Some(protocol_params.default_stake_key),
  }
}

pub fn get_withdraw_state_address(protocol_params: ProtocolParams) -> Address {
  Address {
    payment_credential: ScriptCredential(protocol_params.withdraw_state_skh),
    stake_credential: Some(protocol_params.default_stake_key),
  }
}

pub fn get_withdraw_pool_address(protocol_params: ProtocolParams) -> Address {
  Address {
    payment_credential: ScriptCredential(protocol_params.withdraw_pool_skh),
    stake_credential: Some(protocol_params.default_stake_key),
  }
}

pub fn get_redeem_pool_address(protocol_params: ProtocolParams) -> Address {
  Address {
    payment_credential: ScriptCredential(protocol_params.redeem_pool_skh),
    stake_credential: Some(protocol_params.default_stake_key),
  }
}

pub fn get_operator_fee_address(protocol_params: ProtocolParams) -> Address {
  Address {
    payment_credential: ScriptCredential(protocol_params.operator_fee_skh),
    stake_credential: Some(protocol_params.default_stake_key),
  }
}

pub fn get_platform_fee_address(protocol_params: ProtocolParams) -> Address {
  Address {
    payment_credential: ScriptCredential(protocol_params.platform_fee_skh),
    stake_credential: Some(protocol_params.default_stake_key),
  }
}

pub fn get_vault_state_address(
  protocol_params: ProtocolParams,
  stake: StakeCredential,
) -> Address {
  Address {
    payment_credential: ScriptCredential(protocol_params.vault_state_skh),
    stake_credential: Some(stake),
  }
}

pub fn get_vault_asset_address(
  protocol_params: ProtocolParams,
  stake: StakeCredential,
) -> Address {
  Address {
    payment_credential: ScriptCredential(protocol_params.vault_state_skh),
    stake_credential: Some(stake),
  }
}

pub fn get_dict_ref_inputs(
  club_policy_id: PolicyId,
  protocol_params: ProtocolParams,
  ref_inputs: List<Input>,
) -> Dict<ByteArray, Datum> {
  list.filter_map(
    ref_inputs,
    fn(ref) {
      when ref.output.address.payment_credential is {
        ScriptCredential(skh) ->
          if skh == protocol_params.deposit_state_skh {
            expect datum: DepositStateDatum = output_datum(ref.output)
            if or {
              (club_policy_id != datum.club_policy_id)?,
              value.quantity_of(
                ref.output.value,
                datum.club_policy_id,
                get_deposit_state_nft_name(),
              ) != 1,
            } {
              fail @"deposit_state_nft in deposit_state utxo invalid"
            } else {
              Some((get_deposit_state_nft_name(), ref.output.datum))
            }
          } else if skh == protocol_params.withdraw_state_skh {
            expect datum: WithdrawStateDatum = output_datum(ref.output)
            if or {
              (club_policy_id != datum.club_policy_id)?,
              value.quantity_of(
                ref.output.value,
                datum.club_policy_id,
                get_withdraw_state_nft_name(),
              ) != 1,
            } {
              fail @"withdraw_state_nft in withdraw_state utxo invalid"
            } else {
              Some((get_withdraw_state_nft_name(), ref.output.datum))
            }
          } else if skh == protocol_params.nav_state_skh {
            expect datum: NavStateDatum = output_datum(ref.output)
            if or {
              (club_policy_id != datum.club_policy_id)?,
              value.quantity_of(
                ref.output.value,
                datum.club_policy_id,
                get_nav_nft_name(),
              ) != 1,
            } {
              fail @"nav_nft in nav_state utxo invalid"
            } else {
              Some((get_nav_nft_name(), ref.output.datum))
            }
          } else if skh == protocol_params.general_state_skh {
            expect datum: GeneralStateDatum = output_datum(ref.output)
            if or {
              (club_policy_id != datum.club_policy_id)?,
              value.quantity_of(
                ref.output.value,
                datum.club_policy_id,
                get_general_nft_name(),
              ) != 1,
            } {
              fail @"general_nft in general_state utxo invalid"
            } else {
              Some((get_general_nft_name(), ref.output.datum))
            }
          } else if skh == protocol_params.trading_state_skh {
            expect datum: TradingStateDatum = output_datum(ref.output)
            if or {
              (club_policy_id != datum.club_policy_id)?,
              value.quantity_of(
                ref.output.value,
                datum.club_policy_id,
                get_trading_nft_name(),
              ) != 1,
            } {
              fail @"trading_nft in trading_state utxo invalid"
            } else {
              Some((get_trading_nft_name(), ref.output.datum))
            }
          } else if skh == protocol_params.vault_state_skh {
            expect datum: VaultStateDatum = output_datum(ref.output)
            if or {
              (club_policy_id != datum.club_policy_id)?,
              value.quantity_of(
                ref.output.value,
                datum.club_policy_id,
                get_vault_state_token_name(),
              ) != 1,
            } {
              fail @"vault_state_token in vault_state utxo invalid"
            } else {
              Some((get_vault_state_token_name(), ref.output.datum))
            }
          } else {
            None
          }
        VerificationKeyCredential(_) -> None
      }
    },
  )
    |> dict.from_list(bytearray.compare)
}

pub type RefInputDatum {
  deposit_state: Option<DepositStateDatum>,
  withdraw_state: Option<WithdrawStateDatum>,
  nav_state: Option<NavStateDatum>,
  general_state: Option<GeneralStateDatum>,
  trading_state: Option<TradingStateDatum>,
  vault_state_club_policy_id: ByteArray,
  vault_state: List<(OutputReference, VaultStateDatum)>,
}

pub fn get_tuple_ref_inputs(
  club_policy_id: PolicyId,
  protocol_params: ProtocolParams,
  ref_inputs: List<Input>,
) -> RefInputDatum {
  list.foldr(
    ref_inputs,
    RefInputDatum {
      deposit_state: None,
      withdraw_state: None,
      nav_state: None,
      general_state: None,
      trading_state: None,
      vault_state_club_policy_id: #"",
      vault_state: [],
    },
    fn(ref, z) {
      when ref.output.address.payment_credential is {
        ScriptCredential(skh) ->
          if skh == protocol_params.deposit_state_skh {
            expect datum: DepositStateDatum = output_datum(ref.output)
            if or {
              (club_policy_id != datum.club_policy_id)?,
              value.quantity_of(
                ref.output.value,
                datum.club_policy_id,
                get_deposit_state_nft_name(),
              ) != 1,
            } {
              fail @"deposit_state_nft in deposit_state utxo invalid"
            } else {
              when z.deposit_state is {
                None -> RefInputDatum { ..z, deposit_state: Some(datum) }
                _ -> fail @"deposit_state existed"
              }
            }
          } else if skh == protocol_params.withdraw_state_skh {
            expect datum: WithdrawStateDatum = output_datum(ref.output)
            if or {
              (club_policy_id != datum.club_policy_id)?,
              value.quantity_of(
                ref.output.value,
                datum.club_policy_id,
                get_withdraw_state_nft_name(),
              ) != 1,
            } {
              fail @"withdraw_state_nft in withdraw_state utxo invalid"
            } else {
              when z.withdraw_state is {
                None -> RefInputDatum { ..z, withdraw_state: Some(datum) }
                _ -> fail @"withdraw_state existed"
              }
            }
          } else if skh == protocol_params.nav_state_skh {
            expect datum: NavStateDatum = output_datum(ref.output)
            if or {
              (club_policy_id != datum.club_policy_id)?,
              value.quantity_of(
                ref.output.value,
                datum.club_policy_id,
                get_nav_nft_name(),
              ) != 1,
            } {
              fail @"nav_nft in nav_state utxo invalid"
            } else {
              when z.nav_state is {
                None -> RefInputDatum { ..z, nav_state: Some(datum) }
                _ -> fail @"nav_state existed"
              }
            }
          } else if skh == protocol_params.general_state_skh {
            expect datum: GeneralStateDatum = output_datum(ref.output)
            if or {
              (club_policy_id != datum.club_policy_id)?,
              value.quantity_of(
                ref.output.value,
                datum.club_policy_id,
                get_general_nft_name(),
              ) != 1,
            } {
              fail @"general_nft in general_state utxo invalid"
            } else {
              when z.general_state is {
                None -> RefInputDatum { ..z, general_state: Some(datum) }
                _ -> fail @"general_state existed"
              }
            }
          } else if skh == protocol_params.trading_state_skh {
            expect datum: TradingStateDatum = output_datum(ref.output)
            if or {
              (club_policy_id != datum.club_policy_id)?,
              value.quantity_of(
                ref.output.value,
                datum.club_policy_id,
                get_trading_nft_name(),
              ) != 1,
            } {
              fail @"trading_nft in trading_state utxo invalid"
            } else {
              when z.trading_state is {
                None -> RefInputDatum { ..z, trading_state: Some(datum) }
                _ -> fail @"trading_state existed"
              }
            }
          } else if skh == protocol_params.vault_state_skh {
            expect datum: VaultStateDatum = output_datum(ref.output)
            if or {
              (club_policy_id != datum.club_policy_id)?,
              value.quantity_of(
                ref.output.value,
                datum.club_policy_id,
                get_vault_state_token_name(),
              ) != 1,
            } {
              fail @"vault_state_token in vault_state utxo invalid"
            } else {
              if or {
                datum.club_policy_id == z.vault_state_club_policy_id,
                z.vault_state_club_policy_id == #"",
              } {
                RefInputDatum {
                  ..z,
                  vault_state_club_policy_id: datum.club_policy_id,
                  vault_state: list.push(
                    z.vault_state,
                    (ref.output_reference, datum),
                  ),
                }
              } else {
                fail @"vault_state_club_policy_id invalid"
              }
            }
          } else {
            z
          }
        VerificationKeyCredential(_) -> z
      }
    },
  )
}

pub fn has_operator_nft(club_policy_id: PolicyId, val: Value) {
  value.quantity_of(val, club_policy_id, get_operator_nft_name()) > 0
}

pub fn has_general_nft(club_policy_id: PolicyId, val: Value) {
  value.quantity_of(val, club_policy_id, get_general_nft_name()) > 0
}
