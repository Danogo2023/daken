use aiken/bytearray
use aiken/dict.{Dict}
use aiken/list
use aiken/transaction.{Datum, InlineDatum, Input, OutputReference, Transaction}
use aiken/transaction/credential.{
  Address, PaymentCredential, ScriptCredential, StakeCredential,
  VerificationKeyCredential,
}
use aiken/transaction/value.{AssetName, PolicyId, Value}
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
use club/vault_state/types.{VaultAssetDatum,
  VaultStateDatum} as club_vault_state_types
use club/withdraw_state/types.{WithdrawStateDatum} as club_withdraw_state_types
use common/time.{EpochConfig, SlotConfigNetwork, get_current_epoch_with_ttl}
use common/util.{find_while, must_be_signed_by_key}

/// Check if Operator token is presented in transaction inputs
/// can be used in any transaction that requires Operator token to be valid
/// e.g.: update general utxo, update trading utxo...
pub fn exists_operator_nft(club_pid: PolicyId, txn: Transaction) -> Bool {
  list.any(
    txn.inputs,
    fn(in) {
      value.quantity_of(in.output.value, club_pid, get_operator_nft_name()) > 0
    },
  )
}

/// Must return protocol params from governance UTXO ref
/// can be used in any transaction that require protocol params to validate
/// e.g.: create club needs to validate SM addresses, ...
pub fn get_protocol_params(
  gov_pid: PolicyId,
  ref_inputs: List<Input>,
) -> ProtocolParams {
  let gov_nft = get_gov_nft_name()
  when
    list.find(
      ref_inputs,
      fn(ref) { value.quantity_of(ref.output.value, gov_pid, gov_nft) > 0 },
    )
  is {
    None -> fail @"Not found governance utxo"
    Some(i) -> {
      expect InlineDatum(d) = i.output.datum
      expect pp: ProtocolParams = d
      pp
    }
  }
}

pub fn get_general_state_address(pp: ProtocolParams) -> Address {
  Address {
    payment_credential: ScriptCredential(pp.general_state_skh),
    stake_credential: Some(pp.default_stake_key),
  }
}

pub fn get_trading_state_address(pp: ProtocolParams) -> Address {
  Address {
    payment_credential: ScriptCredential(pp.trading_state_skh),
    stake_credential: Some(pp.default_stake_key),
  }
}

pub fn get_nav_state_address(pp: ProtocolParams) -> Address {
  Address {
    payment_credential: ScriptCredential(pp.nav_state_skh),
    stake_credential: Some(pp.default_stake_key),
  }
}

pub fn get_deposit_state_address(pp: ProtocolParams) -> Address {
  Address {
    payment_credential: ScriptCredential(pp.deposit_state_skh),
    stake_credential: Some(pp.default_stake_key),
  }
}

pub fn get_deposit_pool_address(pp: ProtocolParams) -> Address {
  Address {
    payment_credential: ScriptCredential(pp.deposit_pool_skh),
    stake_credential: Some(pp.default_stake_key),
  }
}

pub fn get_withdraw_state_address(pp: ProtocolParams) -> Address {
  Address {
    payment_credential: ScriptCredential(pp.withdraw_state_skh),
    stake_credential: Some(pp.default_stake_key),
  }
}

pub fn get_withdraw_pool_address(pp: ProtocolParams) -> Address {
  Address {
    payment_credential: ScriptCredential(pp.withdraw_pool_skh),
    stake_credential: Some(pp.default_stake_key),
  }
}

pub fn get_redeem_pool_address(pp: ProtocolParams) -> Address {
  Address {
    payment_credential: ScriptCredential(pp.redeem_pool_skh),
    stake_credential: Some(pp.default_stake_key),
  }
}

pub fn get_operator_fee_address(pp: ProtocolParams) -> Address {
  Address {
    payment_credential: ScriptCredential(pp.operator_fee_skh),
    stake_credential: Some(pp.default_stake_key),
  }
}

pub fn get_platform_fee_address(pp: ProtocolParams) -> Address {
  Address {
    payment_credential: ScriptCredential(pp.platform_fee_skh),
    stake_credential: Some(pp.default_stake_key),
  }
}

pub fn get_vault_state_address(
  pp: ProtocolParams,
  stake: StakeCredential,
) -> Address {
  Address {
    payment_credential: ScriptCredential(pp.vault_state_skh),
    stake_credential: Some(stake),
  }
}

pub fn get_vault_asset_address(
  pp: ProtocolParams,
  stake: StakeCredential,
) -> Address {
  Address {
    payment_credential: ScriptCredential(pp.vault_state_skh),
    stake_credential: Some(stake),
  }
}

pub fn get_general_state_pkey(pp: ProtocolParams) -> PaymentCredential {
  ScriptCredential(pp.general_state_skh)
}

pub fn get_trading_state_pkey(pp: ProtocolParams) -> PaymentCredential {
  ScriptCredential(pp.trading_state_skh)
}

pub fn get_nav_state_pkey(pp: ProtocolParams) -> PaymentCredential {
  ScriptCredential(pp.nav_state_skh)
}

pub fn get_deposit_state_pkey(pp: ProtocolParams) -> PaymentCredential {
  ScriptCredential(pp.deposit_state_skh)
}

pub fn get_deposit_pool_pkey(pp: ProtocolParams) -> PaymentCredential {
  ScriptCredential(pp.deposit_pool_skh)
}

pub fn get_withdraw_state_pkey(pp: ProtocolParams) -> PaymentCredential {
  ScriptCredential(pp.withdraw_state_skh)
}

pub fn get_withdraw_pool_pkey(pp: ProtocolParams) -> PaymentCredential {
  ScriptCredential(pp.withdraw_pool_skh)
}

pub fn get_redeem_pool_pkey(pp: ProtocolParams) -> PaymentCredential {
  ScriptCredential(pp.redeem_pool_skh)
}

pub fn get_operator_fee_pkey(pp: ProtocolParams) -> PaymentCredential {
  ScriptCredential(pp.operator_fee_skh)
}

pub fn get_platform_fee_pkey(pp: ProtocolParams) -> PaymentCredential {
  ScriptCredential(pp.platform_fee_skh)
}

pub fn get_vault_state_pkey(pp: ProtocolParams) -> PaymentCredential {
  ScriptCredential(pp.vault_state_skh)
}

pub fn get_vault_asset_pkey(pp: ProtocolParams) -> PaymentCredential {
  ScriptCredential(pp.vault_state_skh)
}

pub fn get_dict_ref_inputs(
  club_pid: PolicyId,
  pp: ProtocolParams,
  ref_inputs: List<Input>,
) -> Dict<ByteArray, Datum> {
  let general_state_nft = get_general_nft_name()
  let trading_state_nft = get_trading_nft_name()
  let deposit_state_nft = get_deposit_state_nft_name()
  let withdraw_state_nft = get_withdraw_state_nft_name()
  let nav_state_nft = get_nav_nft_name()
  let vault_state_token = get_vault_state_token_name()

  list.filter_map(
    ref_inputs,
    fn(ref) {
      when ref.output.address.payment_credential is {
        ScriptCredential(skh) ->
          if skh == pp.deposit_state_skh {
            expect InlineDatum(d) = ref.output.datum
            expect datum: DepositStateDatum = d
            if or {
              (datum.club_policy_id != club_pid)?,
              value.quantity_of(ref.output.value, club_pid, deposit_state_nft) != 1,
            } {
              fail @"deposit_state_nft in deposit_state utxo invalid"
            } else {
              Some((deposit_state_nft, ref.output.datum))
            }
          } else if skh == pp.withdraw_state_skh {
            expect InlineDatum(d) = ref.output.datum
            expect datum: WithdrawStateDatum = d
            if or {
              (datum.club_policy_id != club_pid)?,
              value.quantity_of(ref.output.value, club_pid, withdraw_state_nft) != 1,
            } {
              fail @"withdraw_state_nft in withdraw_state utxo invalid"
            } else {
              Some((withdraw_state_nft, ref.output.datum))
            }
          } else if skh == pp.nav_state_skh {
            expect InlineDatum(d) = ref.output.datum
            expect datum: NavStateDatum = d
            if or {
              (datum.club_policy_id != club_pid)?,
              value.quantity_of(ref.output.value, club_pid, nav_state_nft) != 1,
            } {
              fail @"nav_nft in nav_state utxo invalid"
            } else {
              Some((nav_state_nft, ref.output.datum))
            }
          } else if skh == pp.general_state_skh {
            expect InlineDatum(d) = ref.output.datum
            expect datum: GeneralStateDatum = d
            if or {
              (datum.club_policy_id != club_pid)?,
              value.quantity_of(ref.output.value, club_pid, general_state_nft) != 1,
            } {
              fail @"general_nft in general_state utxo invalid"
            } else {
              Some((general_state_nft, ref.output.datum))
            }
          } else if skh == pp.trading_state_skh {
            expect InlineDatum(d) = ref.output.datum
            expect datum: TradingStateDatum = d
            if or {
              (datum.club_policy_id != club_pid)?,
              value.quantity_of(ref.output.value, club_pid, trading_state_nft) != 1,
            } {
              fail @"trading_nft in trading_state utxo invalid"
            } else {
              Some((trading_state_nft, ref.output.datum))
            }
          } else if skh == pp.vault_state_skh {
            expect InlineDatum(d) = ref.output.datum
            if
            value.quantity_of(ref.output.value, club_pid, vault_state_token) != 1{
            
              expect _datum: VaultAssetDatum = d
              // this is vault asset
              None
            } else {
              // this is vault state
              expect datum: VaultStateDatum = d
              if (datum.club_policy_id != club_pid)? {
                fail @"vault_state_token in vault_state utxo invalid"
              } else {
                Some((vault_state_token, ref.output.datum))
              }
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
  vault_state_club_pid: PolicyId,
  vault_state: List<(OutputReference, VaultStateDatum)>,
}

// loop one time in ref to get all datum of ref inputs, if present
pub fn get_tuple_ref_inputs(
  club_pid: PolicyId,
  pp: ProtocolParams,
  ref_inputs: List<Input>,
) -> RefInputDatum {
  let general_state_pk = get_general_state_pkey(pp)
  let trading_state_pk = get_trading_state_pkey(pp)
  let deposit_state_pk = get_deposit_state_pkey(pp)
  let withdraw_state_pk = get_withdraw_state_pkey(pp)
  let nav_state_pk = get_nav_state_pkey(pp)
  let vault_state_pk = get_vault_state_pkey(pp)

  let general_state_nft = get_general_nft_name()
  let trading_state_nft = get_trading_nft_name()
  let deposit_state_nft = get_deposit_state_nft_name()
  let withdraw_state_nft = get_withdraw_state_nft_name()
  let nav_state_nft = get_nav_nft_name()
  let vault_state_token = get_vault_state_token_name()

  list.foldr(
    ref_inputs,
    RefInputDatum {
      deposit_state: None,
      withdraw_state: None,
      nav_state: None,
      general_state: None,
      trading_state: None,
      vault_state_club_pid: #"",
      vault_state: [],
    },
    fn(ref, z) {
      let ref_output_pk = ref.output.address.payment_credential
      expect InlineDatum(d) = ref.output.datum
      if ref_output_pk == deposit_state_pk {
        expect datum: DepositStateDatum = d
        if or {
          (datum.club_policy_id != club_pid)?,
          value.quantity_of(ref.output.value, club_pid, deposit_state_nft) != 1,
        } {
          fail @"deposit_state_nft in deposit_state utxo invalid"
        } else {
          when z.deposit_state is {
            None -> RefInputDatum { ..z, deposit_state: Some(datum) }
            _ -> fail @"deposit_state existed"
          }
        }
      } else if ref_output_pk == withdraw_state_pk {
        expect datum: WithdrawStateDatum = d
        if or {
          (datum.club_policy_id != club_pid)?,
          value.quantity_of(ref.output.value, club_pid, withdraw_state_nft) != 1,
        } {
          fail @"withdraw_state_nft in withdraw_state utxo invalid"
        } else {
          when z.withdraw_state is {
            None -> RefInputDatum { ..z, withdraw_state: Some(datum) }
            _ -> fail @"withdraw_state existed"
          }
        }
      } else if ref_output_pk == nav_state_pk {
        expect datum: NavStateDatum = d
        if or {
          (datum.club_policy_id != club_pid)?,
          value.quantity_of(ref.output.value, club_pid, nav_state_nft) != 1,
        } {
          fail @"nav_nft in nav_state utxo invalid"
        } else {
          when z.nav_state is {
            None -> RefInputDatum { ..z, nav_state: Some(datum) }
            _ -> fail @"nav_state existed"
          }
        }
      } else if ref_output_pk == general_state_pk {
        expect datum: GeneralStateDatum = d
        if or {
          (datum.club_policy_id != club_pid)?,
          value.quantity_of(ref.output.value, club_pid, general_state_nft) != 1,
        } {
          fail @"general_nft in general_state utxo invalid"
        } else {
          when z.general_state is {
            None -> RefInputDatum { ..z, general_state: Some(datum) }
            _ -> fail @"general_state existed"
          }
        }
      } else if ref_output_pk == trading_state_pk {
        expect datum: TradingStateDatum = d
        if or {
          (datum.club_policy_id != club_pid)?,
          value.quantity_of(ref.output.value, club_pid, trading_state_nft) != 1,
        } {
          fail @"trading_nft in trading_state utxo invalid"
        } else {
          when z.trading_state is {
            None -> RefInputDatum { ..z, trading_state: Some(datum) }
            _ -> fail @"trading_state existed"
          }
        }
      } else if ref_output_pk == vault_state_pk {
        if
        value.quantity_of(ref.output.value, club_pid, vault_state_token) != 1{
        
          // this is vault asset
          expect _datum: VaultAssetDatum = d
          z
        } else {
          // this is vault state
          expect datum: VaultStateDatum = d
          if (datum.club_policy_id != club_pid)? {
            fail @"policy in vault_state utxo invalid"
          } else {
            if or {
              datum.club_policy_id == z.vault_state_club_pid,
              z.vault_state_club_pid == #"",
            } {
              RefInputDatum {
                ..z,
                vault_state_club_pid: datum.club_policy_id,
                vault_state: list.push(
                  z.vault_state,
                  (ref.output_reference, datum),
                ),
              }
            } else {
              fail @"vault_state_club_pid invalid"
            }
          }
        }
      } else {
        z
      }
    },
  )
}

pub fn get_general_state_ref_inputs(
  club_pid: PolicyId,
  addr: Address,
  ref_inputs: List<Input>,
) -> GeneralStateDatum {
  let general_state_nft = get_general_nft_name()
  when
    find_while(
      ref_inputs,
      None,
      fn(ref, _) {
        if and {
          ref.output.address == addr,
          value.quantity_of(ref.output.value, club_pid, general_state_nft) > 0,
        } {
          expect InlineDatum(d) = ref.output.datum
          expect datum: GeneralStateDatum = d
          if datum.club_policy_id == club_pid {
            (True, Some(datum))
          } else {
            fail @"club_policy_id miss match in reference general state utxo"
          }
        } else {
          (False, None)
        }
      },
    )
  is {
    Some(v) -> v
    _ -> fail @"ref general state not found"
  }
}

pub fn get_trading_state_ref_inputs(
  club_pid: PolicyId,
  addr: Address,
  ref_inputs: List<Input>,
) -> TradingStateDatum {
  let trading_state_nft = get_trading_nft_name()
  when
    find_while(
      ref_inputs,
      None,
      fn(ref, _) {
        if and {
          ref.output.address == addr,
          value.quantity_of(ref.output.value, club_pid, trading_state_nft) > 0,
        } {
          expect InlineDatum(d) = ref.output.datum
          expect datum: TradingStateDatum = d
          if datum.club_policy_id == club_pid {
            (True, Some(datum))
          } else {
            fail @"club_policy_id miss match in reference trading state utxo"
          }
        } else {
          (False, None)
        }
      },
    )
  is {
    Some(v) -> v
    _ -> fail @"ref trading state not found"
  }
}

pub fn get_deposit_state_ref_inputs(
  club_pid: PolicyId,
  addr: Address,
  ref_inputs: List<Input>,
) -> DepositStateDatum {
  let deposit_state_nft = get_deposit_state_nft_name()
  when
    find_while(
      ref_inputs,
      None,
      fn(ref, _) {
        if and {
          ref.output.address == addr,
          value.quantity_of(ref.output.value, club_pid, deposit_state_nft) > 0,
        } {
          expect InlineDatum(d) = ref.output.datum
          expect datum: DepositStateDatum = d
          if datum.club_policy_id == club_pid {
            (True, Some(datum))
          } else {
            fail @"club_policy_id miss match in reference deposit state utxo"
          }
        } else {
          (False, None)
        }
      },
    )
  is {
    Some(v) -> v
    _ -> fail @"ref deposit state not found"
  }
}

pub fn get_withdraw_state_ref_inputs(
  club_pid: PolicyId,
  addr: Address,
  ref_inputs: List<Input>,
) -> WithdrawStateDatum {
  let withdraw_state_nft = get_withdraw_state_nft_name()
  when
    find_while(
      ref_inputs,
      None,
      fn(ref, _) {
        if and {
          ref.output.address == addr,
          value.quantity_of(ref.output.value, club_pid, withdraw_state_nft) > 0,
        } {
          expect InlineDatum(d) = ref.output.datum
          expect datum: WithdrawStateDatum = d
          if datum.club_policy_id == club_pid {
            (True, Some(datum))
          } else {
            fail @"club_policy_id miss match in reference withdraw state utxo"
          }
        } else {
          (False, None)
        }
      },
    )
  is {
    Some(v) -> v
    _ -> fail @"ref withdraw state not found"
  }
}

pub fn get_nav_state_ref_inputs(
  club_pid: PolicyId,
  addr: Address,
  ref_inputs: List<Input>,
) -> NavStateDatum {
  let nav_state_nft = get_nav_nft_name()
  when
    find_while(
      ref_inputs,
      None,
      fn(ref, _) {
        if and {
          ref.output.address == addr,
          value.quantity_of(ref.output.value, club_pid, nav_state_nft) > 0,
        } {
          expect InlineDatum(d) = ref.output.datum
          expect datum: NavStateDatum = d
          if datum.club_policy_id == club_pid {
            (True, Some(datum))
          } else {
            fail @"club_policy_id miss match in reference nav state utxo"
          }
        } else {
          (False, None)
        }
      },
    )
  is {
    Some(v) -> v
    _ -> fail @"ref nav state not found"
  }
}

pub fn check_dual_token(
  val: Value,
  p1: PolicyId,
  a1: AssetName,
  p2: PolicyId,
  a2: AssetName,
) -> (Int, Int) {
  find_while(
    value.flatten_with(
      val,
      fn(p, a, q) {
        if q > 0 {
          if p == p1 && a == a1 {
            Some((1, 0))
          } else if p == p2 && a == a2 {
            Some((0, 1))
          } else {
            None
          }
        } else {
          None
        }
      },
    ),
    (0, 0),
    fn(i, r) {
      let c1 = r.1st + i.1st
      let c2 = r.2nd + i.2nd
      (c1 > 0 && c2 > 0, (c1, c2))
    },
  )
}

pub fn get_general_state_zip_ref_inputs(
  gov_pid: PolicyId,
  club_pid: PolicyId,
  ref_inputs: List<Input>,
) -> (ProtocolParams, GeneralStateDatum) {
  let gov_nft = get_gov_nft_name()
  let general_state_nft = get_general_nft_name()
  when
    find_while(
      ref_inputs,
      (None, []),
      fn(ref, z) {
        when ref.output.datum is {
          InlineDatum(d) -> {
            let t =
              check_dual_token(
                ref.output.value,
                gov_pid,
                gov_nft,
                club_pid,
                general_state_nft,
              )
            if z.1st == None && t.1st > 0 {
              expect pp: ProtocolParams = d
              (False, (Some(pp), z.2nd))
            } else if t.2nd > 0 {
              expect datum: GeneralStateDatum = d
              if datum.club_policy_id == club_pid {
                (
                  z.1st != None,
                  (z.1st, list.push(z.2nd, (ref.output.address, datum))),
                )
              } else {
                (False, z)
              }
            } else {
              (False, z)
            }
          }
          _ -> (False, z)
        }
      },
    )
  is {
    (None, _) -> fail @"ref governance not found"
    (_, []) -> fail @"ref general state not found"
    (Some(a), [_, ..] as b) -> {
      let pk = get_general_state_pkey(a)
      expect Some((_, d)) =
        list.find(b, fn(i) { i.1st.payment_credential == pk })
      (a, d)
    }
  }
}

pub fn get_trading_state_zip_ref_inputs(
  gov_pid: PolicyId,
  club_pid: PolicyId,
  ref_inputs: List<Input>,
) -> (ProtocolParams, TradingStateDatum) {
  let gov_nft = get_gov_nft_name()
  let trading_state_nft = get_trading_nft_name()
  when
    find_while(
      ref_inputs,
      (None, []),
      fn(ref, z) {
        when ref.output.datum is {
          InlineDatum(d) -> {
            let t =
              check_dual_token(
                ref.output.value,
                gov_pid,
                gov_nft,
                club_pid,
                trading_state_nft,
              )
            if z.1st == None && t.1st > 0 {
              expect pp: ProtocolParams = d
              (False, (Some(pp), z.2nd))
            } else if t.2nd > 0 {
              expect datum: TradingStateDatum = d
              if datum.club_policy_id == club_pid {
                (
                  z.1st != None,
                  (z.1st, list.push(z.2nd, (ref.output.address, datum))),
                )
              } else {
                (False, z)
              }
            } else {
              (False, z)
            }
          }
          _ -> (False, z)
        }
      },
    )
  is {
    (None, _) -> fail @"ref governance not found"
    (_, []) -> fail @"ref trading state not found"
    (Some(a), [_, ..] as b) -> {
      let pk = get_trading_state_pkey(a)
      expect Some((_, d)) =
        list.find(b, fn(i) { i.1st.payment_credential == pk })
      (a, d)
    }
  }
}

pub fn get_deposit_state_zip_ref_inputs(
  gov_pid: PolicyId,
  club_pid: PolicyId,
  ref_inputs: List<Input>,
) -> (ProtocolParams, DepositStateDatum) {
  let gov_nft = get_gov_nft_name()
  let deposit_state_nft = get_deposit_state_nft_name()
  when
    find_while(
      ref_inputs,
      (None, []),
      fn(ref, z) {
        when ref.output.datum is {
          InlineDatum(d) -> {
            let t =
              check_dual_token(
                ref.output.value,
                gov_pid,
                gov_nft,
                club_pid,
                deposit_state_nft,
              )
            if z.1st == None && t.1st > 0 {
              expect pp: ProtocolParams = d
              (False, (Some(pp), z.2nd))
            } else if t.2nd > 0 {
              expect datum: DepositStateDatum = d
              if datum.club_policy_id == club_pid {
                (
                  z.1st != None,
                  (z.1st, list.push(z.2nd, (ref.output.address, datum))),
                )
              } else {
                (False, z)
              }
            } else {
              (False, z)
            }
          }
          _ -> (False, z)
        }
      },
    )
  is {
    (None, _) -> fail @"ref governance not found"
    (_, []) -> fail @"ref deposit state not found"
    (Some(a), [_, ..] as b) -> {
      let pk = get_deposit_state_pkey(a)
      expect Some((_, d)) =
        list.find(b, fn(i) { i.1st.payment_credential == pk })
      (a, d)
    }
  }
}

pub fn get_withdraw_state_zip_ref_inputs(
  gov_pid: PolicyId,
  club_pid: PolicyId,
  ref_inputs: List<Input>,
) -> (ProtocolParams, WithdrawStateDatum) {
  let gov_nft = get_gov_nft_name()
  let withdraw_state_nft = get_withdraw_state_nft_name()
  when
    find_while(
      ref_inputs,
      (None, []),
      fn(ref, z) {
        when ref.output.datum is {
          InlineDatum(d) -> {
            let t =
              check_dual_token(
                ref.output.value,
                gov_pid,
                gov_nft,
                club_pid,
                withdraw_state_nft,
              )
            if z.1st == None && t.1st > 0 {
              expect pp: ProtocolParams = d
              (False, (Some(pp), z.2nd))
            } else if t.2nd > 0 {
              expect datum: WithdrawStateDatum = d
              if datum.club_policy_id == club_pid {
                (
                  z.1st != None,
                  (z.1st, list.push(z.2nd, (ref.output.address, datum))),
                )
              } else {
                (False, z)
              }
            } else {
              (False, z)
            }
          }
          _ -> (False, z)
        }
      },
    )
  is {
    (None, _) -> fail @"ref governance not found"
    (_, []) -> fail @"ref withdraw state not found"
    (Some(a), [_, ..] as b) -> {
      let pk = get_deposit_state_pkey(a)
      expect Some((_, d)) =
        list.find(b, fn(i) { i.1st.payment_credential == pk })
      (a, d)
    }
  }
}

pub fn get_nav_state_ref_zip_inputs(
  gov_pid: PolicyId,
  club_pid: PolicyId,
  ref_inputs: List<Input>,
) -> (ProtocolParams, NavStateDatum) {
  let gov_nft = get_gov_nft_name()
  let nav_state_nft = get_nav_nft_name()
  when
    find_while(
      ref_inputs,
      (None, []),
      fn(ref, z) {
        when ref.output.datum is {
          InlineDatum(d) -> {
            let t =
              check_dual_token(
                ref.output.value,
                gov_pid,
                gov_nft,
                club_pid,
                nav_state_nft,
              )
            if z.1st == None && t.1st > 0 {
              expect pp: ProtocolParams = d
              (False, (Some(pp), z.2nd))
            } else if t.2nd > 0 {
              expect datum: NavStateDatum = d
              if datum.club_policy_id == club_pid {
                (
                  z.1st != None,
                  (z.1st, list.push(z.2nd, (ref.output.address, datum))),
                )
              } else {
                (False, z)
              }
            } else {
              (False, z)
            }
          }
          _ -> (False, z)
        }
      },
    )
  is {
    (None, _) -> fail @"ref governance not found"
    (_, []) -> fail @"ref nav state not found"
    (Some(a), [_, ..] as b) -> {
      let pk = get_deposit_state_pkey(a)
      expect Some((_, d)) =
        list.find(b, fn(i) { i.1st.payment_credential == pk })
      (a, d)
    }
  }
}

pub fn has_operator_nft(club_pid: PolicyId, val: Value) -> Bool {
  value.quantity_of(val, club_pid, get_operator_nft_name()) > 0
}

pub fn has_general_nft(club_pid: PolicyId, val: Value) -> Bool {
  value.quantity_of(val, club_pid, get_general_nft_name()) > 0
}

pub fn has_system_force_redeem(
  tx: Transaction,
  e_cfg: EpochConfig,
  s_cfg: SlotConfigNetwork,
  pp: ProtocolParams,
  ts: TradingStateDatum,
) -> Bool {
  ts.force_closed? && //
  (get_current_epoch_with_ttl(
    tx.validity_range,
    e_cfg,
    pp.tx_ttl * s_cfg.slot_length,
  ) - ts.force_closed_at_epoch > pp.platform_force_redeem_epoch)? && //
  must_be_signed_by_key(tx.extra_signatories, pp.platform_force_redeem_pkh)?
}
