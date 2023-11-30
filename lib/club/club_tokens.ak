use aiken/bytearray
use common/constants
use common/convert.{number_to_bytearray_hex}

pub fn get_operator_nft_name() -> ByteArray {
  bytearray.concat(constants.prefix_222, #"01")
}

pub fn get_general_nft_name() -> ByteArray {
  bytearray.concat(constants.prefix_222, #"02")
}

pub fn get_trading_nft_name() -> ByteArray {
  bytearray.concat(constants.prefix_222, #"03")
}

pub fn get_nav_nft_name() -> ByteArray {
  bytearray.concat(constants.prefix_222, #"05")
}

pub fn get_vault_state_token_name() -> ByteArray {
  bytearray.concat(constants.prefix_222, #"06")
}

pub fn get_deposit_state_nft_name() -> ByteArray {
  bytearray.concat(constants.prefix_222, #"07")
}

pub fn get_withdraw_state_nft_name() -> ByteArray {
  bytearray.concat(constants.prefix_222, #"08")
}

pub fn get_operator_share_token_prefix() -> ByteArray {
  bytearray.concat(constants.prefix_333, #"10")
}

pub fn get_member_share_token_prefix() -> ByteArray {
  bytearray.concat(constants.prefix_333, #"11")
}

pub fn get_deposit_pool_token_name() -> ByteArray {
  bytearray.concat(constants.prefix_333, #"40")
}

pub fn get_deposit_request_token_prefix() -> ByteArray {
  bytearray.concat(constants.prefix_333, #"20")
}

pub fn get_withdraw_pool_token_name() -> ByteArray {
  bytearray.concat(constants.prefix_333, #"50")
}

pub fn get_withdraw_request_token_prefix() -> ByteArray {
  bytearray.concat(constants.prefix_333, #"30")
}

// ========= token with concat names ==========
// <prefixes><epoch mint token - 2bytes><price issue - 8bytes>
pub fn get_share_token_name(
  prefixes: ByteArray,
  epoch_mint_token: Int,
  price_issue: Int,
) -> ByteArray {
  prefixes
    |> bytearray.concat(number_to_bytearray_hex(epoch_mint_token, 2))
    |> bytearray.concat(number_to_bytearray_hex(price_issue, 8))
}

// <prefixes><poolid - 2bytes><timestamp - 6bytes>
pub fn get_deposit_request_token_name(
  pool_id: Int,
  timestamp_ms: Int,
) -> ByteArray {
  get_deposit_request_token_prefix()
    |> bytearray.concat(number_to_bytearray_hex(pool_id, 2))
    |> bytearray.concat(number_to_bytearray_hex(timestamp_ms, 6))
}

// <prefixes><poolid - 2bytes><epoch mint member token - 2bytes><timestamp - 6bytes>
pub fn get_withdraw_request_token_name(
  pool_id: Int,
  epoch_mint_token: Int,
  timestamp_ms: Int,
) -> ByteArray {
  get_withdraw_request_token_prefix()
    |> bytearray.concat(number_to_bytearray_hex(pool_id, 2))
    |> bytearray.concat(number_to_bytearray_hex(epoch_mint_token, 2))
    |> bytearray.concat(number_to_bytearray_hex(timestamp_ms, 6))
}

pub fn is_deposit_request_token_in_pool(name: ByteArray, pool_id: Int) {
  bytearray.take(name, 7) == bytearray.concat(
    get_deposit_request_token_prefix(),
    number_to_bytearray_hex(pool_id, 2),
  )
}

pub fn is_withdraw_request_token_in_pool(name: ByteArray, pool_id: Int) {
  bytearray.take(name, 7) == bytearray.concat(
    get_withdraw_request_token_prefix(),
    number_to_bytearray_hex(pool_id, 2),
  )
}

test get_share_token_name_1() {
  get_share_token_name(#"10", 440, 100_000_000) == #"1001b80000000005f5e100"
}

test get_share_token_name_2() {
  get_share_token_name(#"", 440, 100_000_001) == #"01b80000000005f5e101"
}

test get_deposit_request_token_name_1() {
  get_deposit_request_token_name(2, 1698809450000) == bytearray.concat(
    get_deposit_request_token_prefix(),
    #"0002018b88ef0e10",
  )
}

test get_deposit_request_token_name_2() {
  get_deposit_request_token_name(0, 0) == bytearray.concat(
    get_deposit_request_token_prefix(),
    #"0000000000000000",
  )
}

test get_withdraw_request_token_name_1() {
  get_withdraw_request_token_name(2, 440, 1698809450000) == bytearray.concat(
    get_withdraw_request_token_prefix(),
    #"000201b8018b88ef0e10",
  )
}

test get_withdraw_request_token_name_2() {
  get_withdraw_request_token_name(0, 0, 0) == bytearray.concat(
    get_withdraw_request_token_prefix(),
    #"00000000000000000000",
  )
}

test is_deposit_request_token_in_pool_1() {
  is_deposit_request_token_in_pool(get_deposit_request_token_name(2, 10), 2)
}

test is_deposit_request_token_in_pool_2() {
  !is_deposit_request_token_in_pool(get_deposit_request_token_name(2, 10), 1)
}

test is_deposit_request_token_in_pool_3() {
  !is_deposit_request_token_in_pool(
    get_withdraw_request_token_name(2, 2, 10),
    2,
  )
}

test is_deposit_request_token_in_pool_4() {
  !is_deposit_request_token_in_pool("", 2)
}

test is_withdraw_request_token_in_pool_1() {
  is_withdraw_request_token_in_pool(
    get_withdraw_request_token_name(2, 3, 10),
    2,
  )
}

test is_withdraw_request_token_in_pool_2() {
  !is_withdraw_request_token_in_pool(
    get_withdraw_request_token_name(2, 3, 10),
    1,
  )
}

test is_withdraw_request_token_in_pool_3() {
  !is_withdraw_request_token_in_pool(get_deposit_request_token_name(2, 10), 2)
}

test is_withdraw_request_token_in_pool_4() {
  !is_withdraw_request_token_in_pool("", 2)
}
