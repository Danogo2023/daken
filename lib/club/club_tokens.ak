use aiken/bytearray
use assist/prefixes

pub fn get_operator_nft_name() -> ByteArray {
  bytearray.concat(prefixes.prefix_222, #"01")
}

pub fn get_general_nft_name() -> ByteArray {
  bytearray.concat(prefixes.prefix_222, #"02")
}

pub fn get_trading_nft_name() -> ByteArray {
  bytearray.concat(prefixes.prefix_222, #"03")
}

pub fn get_nav_nft_name() -> ByteArray {
  bytearray.concat(prefixes.prefix_222, #"05")
}

pub fn get_vault_state_token_name() -> ByteArray {
  bytearray.concat(prefixes.prefix_222, #"06")
}

pub fn get_deposit_state_nft_name() -> ByteArray {
  bytearray.concat(prefixes.prefix_222, #"07")
}

pub fn get_withdraw_state_nft_name() -> ByteArray {
  bytearray.concat(prefixes.prefix_222, #"08")
}

pub fn get_deposit_pool_nft_name() -> ByteArray {
  bytearray.concat(prefixes.prefix_333, #"40")
}

pub fn get_withdraw_pool_nft_name() -> ByteArray {
  bytearray.concat(prefixes.prefix_333, #"50")
}
