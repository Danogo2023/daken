use aiken/bytearray
use club/constants
use common/util.{get_number_from_hex_string}

pub type ClubToken {
  // op nft
  OperatorNft
  // tokens for utxos
  GeneralNft
  TradingNft
  ForceNft
  NavNft
  VaultStateNft
  DepositStateNft
  WithdrawStateNft
  // share token
  OperatorShareToken { epoch_mint_token: Int, share_token_price_issue: Int }
  MemberShareToken { epoch_mint_token: Int, share_token_price_issue: Int }
  // request token
  DepositRequestToken { pool_id: Int, timestamp: Int }
  WithdrawRequestToken { pool_id: Int, token_epoch: Int, timestamp: Int }
  // pool
  DepositPoolToken
  WithdrawPoolToken
  //
  UnknownToken
}

pub fn find_club_token_type_from_name(name: ByteArray) -> ClubToken {
  // why aiken does not support "when *string* is {}" ??
  let prefix = bytearray.take(name, 1)
  if prefix == constants.operator_nft_prefix {
    OperatorNft
  } else if prefix == constants.config_nft_prefix {
    GeneralNft
  } else if prefix == constants.trading_nft_prefix {
    TradingNft
  } else if prefix == constants.force_nft_prefix {
    ForceNft
  } else if prefix == constants.nav_nft_prefix {
    NavNft
  } else if prefix == constants.vault_state_token_prefix {
    VaultStateNft
  } else if prefix == constants.deposit_state_nft_prefix {
    DepositStateNft
  } else if prefix == constants.withdraw_state_nft_prefix {
    WithdrawStateNft
  } else if prefix == constants.operator_share_token_prefix {
    if bytearray.length(name) != 11 {
      UnknownToken
    } else {
      OperatorShareToken(
        get_number_from_hex_string(bytearray.slice(name, 1, 2)),
        get_number_from_hex_string(bytearray.slice(name, 3, 10)),
      )
    }
  } else if prefix == constants.member_share_token_prefix {
    if bytearray.length(name) != 11 {
      UnknownToken
    } else {
      MemberShareToken(
        get_number_from_hex_string(bytearray.slice(name, 1, 2)),
        get_number_from_hex_string(bytearray.slice(name, 3, 10)),
      )
    }
  } else if prefix == constants.deposit_request_token_prefix {
    if bytearray.length(name) != 8 {
      UnknownToken
    } else {
      DepositRequestToken(
        get_number_from_hex_string(bytearray.slice(name, 1, 2)),
        get_number_from_hex_string(bytearray.slice(name, 3, 7)),
      )
    }
  } else if prefix == constants.withdraw_request_token_prefix {
    if bytearray.length(name) != 10 {
      UnknownToken
    } else {
      WithdrawRequestToken(
        get_number_from_hex_string(bytearray.slice(name, 1, 2)),
        get_number_from_hex_string(bytearray.slice(name, 3, 4)),
        get_number_from_hex_string(bytearray.slice(name, 5, 9)),
      )
    }
  } else if prefix == constants.deposit_pool_token_prefix {
    DepositPoolToken
  } else if prefix == constants.withdraw_pool_token_prefix {
    WithdrawPoolToken
  } else {
    // todo
    UnknownToken
  }
}

test name_converting_test1() {
  find_club_token_type_from_name(#"01") == OperatorNft
}

test name_converting_test2() {
  find_club_token_type_from_name(#"02") == GeneralNft
}

test name_converting_test3() {
  find_club_token_type_from_name(#"03") == TradingNft
}

test name_converting_test4() {
  find_club_token_type_from_name(#"04") == ForceNft
}

test name_converting_test5() {
  find_club_token_type_from_name(#"05") == NavNft
}

test name_converting_test6() {
  find_club_token_type_from_name(#"06") == VaultStateNft
}

test name_converting_test7() {
  find_club_token_type_from_name(#"07") == DepositStateNft
}

test name_converting_test8() {
  find_club_token_type_from_name(#"08") == WithdrawStateNft
}

//-------------------------------------
// share token
test name_converting_test9() {
  find_club_token_type_from_name(#"1001b90000000005f5e101") == OperatorShareToken(
    441,
    100_000_001,
  )
}

test name_converting_test10() {
  find_club_token_type_from_name(#"1101b80000000005f5e100") == MemberShareToken(
    440,
    100_000_000,
  )
}

//-------------------------------------
// request token
test name_converting_test11() {
  find_club_token_type_from_name(#"20007b006541c66a") == DepositRequestToken(
    123,
    1_698_809_450,
  )
}

test name_converting_test12() {
  find_club_token_type_from_name(#"30007b01b8006541c66a") == WithdrawRequestToken(
    123,
    440,
    1_698_809_450,
  )
}

// ----------
// pool
test name_converting_test13() {
  find_club_token_type_from_name(#"40") == DepositPoolToken
}

test name_converting_test14() {
  find_club_token_type_from_name(#"50") == WithdrawPoolToken
}

test name_converting_test15() {
  find_club_token_type_from_name(#"30000501b80000000000000064006541") == UnknownToken
}
