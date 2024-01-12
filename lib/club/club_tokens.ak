use aiken/bytearray
use aiken/interval.{Finite}
use aiken/transaction.{ValidityRange}
use common/constants
use common/convert.{number_to_bytearray_hex}
use common/time.{SlotConfig}
use common/util.{get_number_from_hex_string}

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

pub fn get_operator_share_token_name(
  epoch_mint_token: Int,
  price_issue: Int,
) -> ByteArray {
  get_operator_share_token_prefix()
    |> bytearray.concat(number_to_bytearray_hex(epoch_mint_token, 2))
    |> bytearray.concat(number_to_bytearray_hex(price_issue, 8))
}

pub fn get_member_share_token_name(
  epoch_mint_token: Int,
  price_issue: Int,
) -> ByteArray {
  get_member_share_token_prefix()
    |> bytearray.concat(number_to_bytearray_hex(epoch_mint_token, 2))
    |> bytearray.concat(number_to_bytearray_hex(price_issue, 8))
}

// token name = <prefixes: 5 bytes><epoch: 2 bytes><issue_price: 8 bytes> -> (epoch, issue_price)
pub fn get_epoch_price_from_share_token_name(name: ByteArray) {
  let epoch = get_number_from_hex_string(bytearray.slice(name, 5, 6))
  let issue_price = get_number_from_hex_string(bytearray.slice(name, 7, 14))
  (epoch, issue_price)
}

// <prefixes><poolid - 2bytes><timestamp - 6bytes>
pub fn get_deposit_request_token_name(
  pool_id: Int,
  validity_range: ValidityRange,
  _slot_config: SlotConfig,
) -> ByteArray {
  let lowerbound =
    when validity_range.lower_bound.bound_type is {
      Finite(lower) -> lower
      _ -> fail @"Wrong validity range"
    }
  get_deposit_request_token_prefix()
    |> bytearray.concat(number_to_bytearray_hex(pool_id, 2))
    |> bytearray.concat(number_to_bytearray_hex(lowerbound, 6))
}

// <prefixes><poolid - 2bytes><epoch mint member token - 2bytes><issue_price: 8 bytes><timestamp - 6bytes>
pub fn get_withdraw_request_token_name(
  pool_id: Int,
  epoch_mint_token: Int,
  issue_price: Int,
  validity_range: ValidityRange,
  _slot_config: SlotConfig,
) -> ByteArray {
  let lowerbound =
    when validity_range.lower_bound.bound_type is {
      Finite(lower) -> lower
      _ -> fail @"Wrong validity range"
    }
  get_withdraw_request_token_prefix()
    |> bytearray.concat(number_to_bytearray_hex(pool_id, 2))
    |> bytearray.concat(number_to_bytearray_hex(epoch_mint_token, 2))
    |> bytearray.concat(number_to_bytearray_hex(issue_price, 8))
    |> bytearray.concat(number_to_bytearray_hex(lowerbound, 6))
}

// withdraw request token name = <prefixes><poolid - 2bytes><epoch mint member token - 2bytes><issue_price: 8 bytes><timestamp - 6bytes>
pub fn get_epoch_price_from_withdraw_request_token_name(name: ByteArray) {
  let epoch = get_number_from_hex_string(bytearray.slice(name, 7, 8))
  let issue_price = get_number_from_hex_string(bytearray.slice(name, 9, 16))
  (epoch, issue_price)
}

// =================== check token by name ==================
pub fn is_operator_share_token(name: ByteArray) {
  bytearray.take(name, 5) == get_operator_share_token_prefix()
}

pub fn is_member_share_token(name: ByteArray) {
  bytearray.take(name, 5) == get_member_share_token_prefix()
}

pub fn is_deposit_request_token(name: ByteArray) {
  bytearray.take(name, 5) == get_deposit_request_token_prefix()
}

pub fn is_deposit_request_token_in_pool(name: ByteArray, pool_id: Int) {
  bytearray.take(name, 7) == bytearray.concat(
    get_deposit_request_token_prefix(),
    number_to_bytearray_hex(pool_id, 2),
  )
}

pub fn is_withdraw_request_token(name: ByteArray) {
  bytearray.take(name, 5) == get_withdraw_request_token_prefix()
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

test correct_epoch_price_share_token_name_1() {
  let (epoch, price) =
    get_epoch_price_from_share_token_name(
      get_share_token_name(get_member_share_token_prefix(), 440, 100_000_000),
    )
  epoch == 440 && price == 100_000_000
}

test correct_epoch_price_share_token_name_2() {
  let (epoch, price) =
    get_epoch_price_from_share_token_name(
      get_share_token_name(get_operator_share_token_prefix(), 440, 100_000_000),
    )
  epoch == 440 && price == 100_000_000
}

test correct_epoch_price_from_withdraw_request_token_name_1() {
  let (epoch, price) =
    get_epoch_price_from_withdraw_request_token_name(
      get_withdraw_request_token_name(
        2,
        440,
        100_000_000,
        interval.between(1698809450000, 1698809450001),
        time.get_slot_config_network_mainnet(),
      ),
    )
  epoch == 440 && price == 100_000_000
}

test get_share_token_name_2() {
  get_share_token_name(#"", 440, 100_000_001) == #"01b80000000005f5e101"
}

//
test get_deposit_request_token_name_1() {
  get_deposit_request_token_name(
    2,
    interval.between(1698809450000, 1698809450001),
    time.get_slot_config_network_mainnet(),
  ) == bytearray.concat(get_deposit_request_token_prefix(), #"0002018b88ef0e10")
}

test get_deposit_request_token_name_2() {
  get_deposit_request_token_name(
    0,
    interval.between(0, 0),
    time.get_slot_config_network_mainnet(),
  ) == bytearray.concat(get_deposit_request_token_prefix(), #"0000000000000000")
}

test get_deposit_request_token_name_3() fail {
  get_deposit_request_token_name(
    0,
    interval.everything(),
    time.get_slot_config_network_mainnet(),
  ) == bytearray.concat(get_deposit_request_token_prefix(), #"0000000000000000")
}

//
test get_withdraw_request_token_name_1() {
  get_withdraw_request_token_name(
    2,
    440,
    100_000_000,
    interval.between(1698809450000, 1698809450001),
    time.get_slot_config_network_mainnet(),
  ) == bytearray.concat(
    get_withdraw_request_token_prefix(),
    #"000201b80000000005f5e100018b88ef0e10",
  )
}

test get_withdraw_request_token_name_2() {
  get_withdraw_request_token_name(
    0,
    0,
    0,
    interval.between(0, 0),
    time.get_slot_config_network_mainnet(),
  ) == bytearray.concat(
    get_withdraw_request_token_prefix(),
    #"000000000000000000000000000000000000",
  )
}

test get_withdraw_request_token_name_3() fail {
  get_withdraw_request_token_name(
    0,
    0,
    0,
    interval.everything(),
    time.get_slot_config_network_mainnet(),
  ) == bytearray.concat(
    get_withdraw_request_token_prefix(),
    #"000000000000000000000000000000000000",
  )
}

//
test is_member_share_token_1() {
  is_member_share_token(
    get_share_token_name(get_member_share_token_prefix(), 440, 100_000_000),
  )
}

test is_member_share_token_2() {
  !is_member_share_token(
    get_share_token_name(get_operator_share_token_prefix(), 440, 100_000_000),
  )
}

test is_deposit_request_token_in_pool_1() {
  is_deposit_request_token_in_pool(
    get_deposit_request_token_name(
      2,
      interval.between(1698809450000, 1698809450001),
      time.get_slot_config_network_mainnet(),
    ),
    2,
  )
}

test is_deposit_request_token_in_pool_2() {
  !is_deposit_request_token_in_pool(
    get_deposit_request_token_name(
      2,
      interval.between(1698809450000, 1698809450001),
      time.get_slot_config_network_mainnet(),
    ),
    1,
  )
}

test is_deposit_request_token_in_pool_3() {
  !is_deposit_request_token_in_pool(
    get_withdraw_request_token_name(
      2,
      440,
      100_000_000,
      interval.between(1698809450000, 1698809450001),
      time.get_slot_config_network_mainnet(),
    ),
    2,
  )
}

test is_deposit_request_token_in_pool_4() {
  !is_deposit_request_token_in_pool("", 2)
}

test is_withdraw_request_token_in_pool_1() {
  is_withdraw_request_token_in_pool(
    get_withdraw_request_token_name(
      2,
      440,
      100_000_000,
      interval.between(1698809450000, 1698809450001),
      time.get_slot_config_network_mainnet(),
    ),
    2,
  )
}

test is_withdraw_request_token_in_pool_2() {
  !is_withdraw_request_token_in_pool(
    get_withdraw_request_token_name(
      2,
      440,
      100_000_000,
      interval.between(1698809450000, 1698809450001),
      time.get_slot_config_network_mainnet(),
    ),
    1,
  )
}

test is_withdraw_request_token_in_pool_3() {
  !is_withdraw_request_token_in_pool(
    get_deposit_request_token_name(
      2,
      interval.between(1698809450000, 1698809450001),
      time.get_slot_config_network_mainnet(),
    ),
    2,
  )
}

test is_withdraw_request_token_in_pool_4() {
  !is_withdraw_request_token_in_pool("", 2)
}
