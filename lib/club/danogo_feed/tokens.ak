use aiken/bytearray
use common/constants

// Danogo Club Governance
pub fn get_gov_nft_name() -> ByteArray {
  bytearray.concat(constants.prefix_nft, "gDGC")
}

// Danogo Club Price Feed
pub fn get_price_feed_token_name() -> ByteArray {
  bytearray.concat(constants.prefix_ft, "pDGC")
}

// Danogo Club Stake Key
pub fn get_stake_key_token_name() -> ByteArray {
  bytearray.concat(constants.prefix_ft, "sDGC")
}

// Danogo Club Defi Protocol Feed
pub fn get_defi_protocol_token_name() -> ByteArray {
  bytearray.concat(constants.prefix_ft, "dDGC")
}
