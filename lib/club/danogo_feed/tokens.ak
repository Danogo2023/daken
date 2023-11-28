use aiken/bytearray
use assist/prefixes

// Danogo Club Governance
pub fn get_gov_nft_name() -> ByteArray {
  bytearray.concat(prefixes.prefix_222, "gDGC")
}

// Danogo Club Price Feed
pub fn get_price_feed_token_name() -> ByteArray {
  bytearray.concat(prefixes.prefix_333, "pDGC")
}

// Danogo Club Stake Key
pub fn get_stake_key_token_name() -> ByteArray {
  bytearray.concat(prefixes.prefix_333, "sDGC")
}

// Danogo Club Defi Protocol Feed
pub fn get_defi_protocol_token_name() -> ByteArray {
  bytearray.concat(prefixes.prefix_333, "dDGC")
}
