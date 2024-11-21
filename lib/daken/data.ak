use aiken/builtin
use aiken/collection/dict.{Dict}
use aiken/collection/list
use aiken/collection/pairs
use aiken/interval.{Finite, Interval, IntervalBound}
use cardano/address.{
  Address, Inline, PaymentCredential, StakeCredential, VerificationKey,
}
use cardano/assets.{AssetName, PolicyId}
use cardano/transaction.{InlineDatum, Input, Output}
use daken/convert.{int_to_digit}
use daken/pvalue.{PValue}
use daken/types.{PublicKeyHash}

pub fn input_datum(possible_input: Input) -> Data {
  expect InlineDatum(inbound_datum) = possible_input.output.datum
  inbound_datum
}

pub fn output_datum(possible_output: Output) -> Data {
  expect InlineDatum(outbound_datum) = possible_output.datum
  outbound_datum
}

pub fn get_data_with_idx(data: Data, target_idxs: List<Int>) {
  let (_, _, elements) = do_get_data_with_idx(data, [], 0, target_idxs, [])
  when elements is {
    [] -> fail @"Not found data with idx"
    _ -> elements
  }
}

fn do_get_data_with_idx(
  data: Data,
  result: Pairs<Int, ByteArray>,
  index: Int,
  target_indices: List<Int>,
  found_elements: Pairs<Int, List<ByteArray>>,
) -> (Pairs<Int, ByteArray>, Int, Pairs<Int, List<ByteArray>>) {
  if list.all(target_indices, fn(target_index) { index > target_index }) {
    // Stop processing if the current index exceeds all target indices
    (result, index, found_elements)
  } else {
    builtin.choose_data(
      data,
      {
        // Constructor case
        let Pair(constr, fields) = builtin.un_constr_data(data)
        let root_idx = index + 1
        let (new_result, new_index, new_found_elements) =
          list.foldr(
            fields,
            (result, root_idx + 1, found_elements),
            // Tăng index khi đi vào constructor
            fn(
              e: Data,
              (st, idx, found): (
                Pairs<Int, ByteArray>,
                Int,
                Pairs<Int, List<ByteArray>>,
              ),
            ) {
              do_get_data_with_idx(e, st, idx, target_indices, found)
            },
          )

        // Giữ nguyên idx cho các field cùng cấp
        let constr_tag =
          if constr < 7 {
            121 + constr
          } else if constr < 128 {
            1280 + constr - 7
          } else {
            fail @"Invalid constructor tag"
          }
        let constr_tag_hex = int_to_digit(constr_tag)
        let pair = Pair(root_idx, constr_tag_hex)
        let updated_found_elements =
          if list.has(target_indices, root_idx) {
            let existing =
              list.find(new_found_elements, fn(p) { p.1st == root_idx })
            let updated_list =
              when existing is {
                Some(Pair(_, lst)) -> [constr_tag_hex, ..lst]
                None -> [constr_tag_hex]
              }
            [
              Pair(root_idx, updated_list),
              ..list.filter(new_found_elements, fn(p) { p.1st != root_idx })
            ]
          } else {
            new_found_elements
          }
        ([pair, ..new_result], new_index, updated_found_elements)
      },
      {
        // Map case
        let elements = builtin.un_map_data(data)
        let root_idx = index + 1
        list.foldr(
          elements,
          (result, index, found_elements),
          fn(
            e: Pair<Data, Data>,
            (st, _idx, found): (
              Pairs<Int, ByteArray>,
              Int,
              Pairs<Int, List<ByteArray>>,
            ),
          ) {
            let (key_result, k, key_found) =
              do_get_data_with_idx(e.1st, [], root_idx, target_indices, found)
            let (value_result, v, value_found) =
              do_get_data_with_idx(e.2nd, [], k + 1, target_indices, key_found)
            (
              list.concat(key_result, list.concat(value_result, st)),
              v,
              value_found,
            )
          },
        )
      },
      {
        // List case
        let elements = builtin.un_list_data(data)
        let root_idx = index + 1
        list.foldr(
          elements,
          (result, index, found_elements),
          fn(
            e: Data,
            (st, _idx, found): (
              Pairs<Int, ByteArray>,
              Int,
              Pairs<Int, List<ByteArray>>,
            ),
          ) {
            let (elem_result, new_index, elem_found) =
              do_get_data_with_idx(e, [], root_idx, target_indices, found)
            (list.concat(elem_result, st), new_index + 1, elem_found)
          },
        )
      },
      {
        // Integer case
        let i = builtin.un_i_data(data)
        let new_index = index + 1
        let i_hex = int_to_digit(i)
        let pair = Pair(new_index, i_hex)
        let updated_found_elements =
          updated_found_elements(
            target_indices,
            new_index,
            i_hex,
            found_elements,
          )
        ([pair, ..result], new_index, updated_found_elements)
      },
      {
        // ByteArray case
        let b = builtin.un_b_data(data)
        let new_index = index + 1
        let pair = Pair(new_index, b)
        let updated_found_elements =
          updated_found_elements(target_indices, new_index, b, found_elements)
        ([pair, ..result], new_index, updated_found_elements)
      },
    )
  }
}

fn updated_found_elements(
  target_indices: List<Int>,
  new_index: Int,
  pre_dt: ByteArray,
  found_elements: Pairs<Int, List<ByteArray>>,
) {
  if list.has(target_indices, new_index) {
    let existing = list.find(found_elements, fn(p) { p.1st == new_index })
    let updated_list =
      when existing is {
        Some(Pair(_, lst)) -> [pre_dt, ..lst]
        None -> [pre_dt]
      }
    [
      Pair(new_index, updated_list),
      ..list.filter(found_elements, fn(p) { p.1st != new_index })
    ]
  } else {
    found_elements
  }
}

pub fn flatten_dt(data: Data) {
  do_flatten_dt(data, [], 0)
}

pub fn do_flatten_dt(
  data: Data,
  result: List<Pair<Int, ByteArray>>,
  index: Int,
) -> (List<Pair<Int, ByteArray>>, Int) {
  builtin.choose_data(
    data,
    {
      // Constructor case
      let Pair(constr, fields) = builtin.un_constr_data(data)
      let root_idx = index + 1
      let (result, new_index) =
        list.foldr(
          fields,
          (result, root_idx + 1),
          // Tăng index khi đi vào constructor
          fn(e: Data, acc: (List<Pair<Int, ByteArray>>, Int)) {
            let (st, idx) = acc
            do_flatten_dt(e, st, idx)
          },
        )

      // Giữ nguyên idx cho các field cùng cấp
      let constr_tag =
        if constr < 7 {
          121 + constr
        } else if constr < 128 {
          1280 + constr - 7
        } else {
          fail @"Invalid constructor tag"
        }
      ([Pair(root_idx, int_to_digit(constr_tag)), ..result], new_index)
    },
    {
      // Map case
      let elements = builtin.un_map_data(data)
      let root_idx = index + 1
      when elements is {
        [] -> (result, index)
        _ ->
          list.foldr(
            elements,
            (result, index),
            fn(e: Pair<Data, Data>, acc: (List<Pair<Int, ByteArray>>, Int)) {
              let (st, _idx) = acc
              let (key_result, k) = do_flatten_dt(e.1st, [], root_idx)
              // Các key cùng cấp dùng chung index
              let (value_result, v) = do_flatten_dt(e.2nd, [], k + 1)
              // Các value cùng cấp dùng chung index
              (key_result |> list.concat(value_result) |> list.concat(st), v)
            },
          )
      }
    },
    {
      // List case
      let elements = builtin.un_list_data(data)
      let root_idx = index + 1
      list.foldr(
        elements,
        (result, index),
        fn(e: Data, acc: (List<Pair<Int, ByteArray>>, Int)) {
          let (st, _idx) = acc
          let (elem_result, new_index) = do_flatten_dt(e, [], root_idx)
          // Các phần tử trong list cùng cấp
          (list.concat(elem_result, st), new_index + 1)
        },
      )
    },
    {
      // Integer case
      let i = builtin.un_i_data(data)
      let new_index = index + 1
      ([Pair(new_index, int_to_digit(i)), ..result], new_index)
    },
    {
      // ByteArray case
      let b = builtin.un_b_data(data)
      let new_index = index + 1
      ([Pair(new_index, b), ..result], new_index)
    },
  )
}

// Tests

type DatumTest {
  dict: Dict<ByteArray, Dict<ByteArray, Int>>,
  tuple: (Int, Int, Int, Int),
  bytearray: ByteArray,
  int: Int,
  list: List<Int>,
  tuple_tuple: ((Int, Int), (Int, Int), (Int, Int), (Int, Int)),
  some: Option<ByteArray>,
  vkh: PaymentCredential,
  skh: Option<StakeCredential>,
  addr: Address,
  nest: DatumTestNest1,
  nest2: DatumTestNest1,
  some_tuple: Option<(Int, Int)>,
  none: Option<Int>,
  dict2: Dict<ByteArray, List<(Int, ByteArray)>>,
}

type DatumTestNest1 {
  First { item: Option<ByteArray> }
  Second { item: DatumTestNest2 }
}

type DatumTestNest2 {
  Thirdly {
    interval: Interval<Int>,
    pairs: Pairs<Int, (Int, Int)>,
    list_items: List<(List<Int>, List<ByteArray>)>,
  }
}

test success_get_data_with_idx_when_complex_structure() {
  let datum =
    DatumTest {
      dict: dict.empty
        |> dict.insert(
            "123",
            dict.empty
              |> dict.insert("s1", 0)
              |> dict.insert("s2", 1),
          )
        |> dict.insert(
            "1234",
            dict.empty
              |> dict.insert("s5", 0)
              |> dict.insert("s6", 5),
          ),
      int: 90000000,
      tuple: (10, 8, 1, 1),
      bytearray: #"c03bf2bd26327637e1910410a363cca092d89d5b6a89641602dcc268",
      list: [809, 1000],
      tuple_tuple: (
        (8442487033, 4503599627370496),
        (21817265503, 10000000000000000),
        (15427053409, 125000000000000),
        (9, 10),
      ),
      some: Some(#"d87980"),
      vkh: VerificationKey(
        #"ec5a9f9bb81ca16b05a0dedbb47a51ca7e0d09ae88a0fc221e549cf8",
      ),
      skh: Some(
        Inline(
          VerificationKey(
            #"ec5a9f9bb81ca16b05a0dedbb47a51ca7e0d09ae88a0fc221e549cf8",
          ),
        ),
      ),
      addr: address.from_script("script")
        |> address.with_delegation_script("stake"),
      nest: Second(
        Thirdly {
          interval: Interval {
            lower_bound: IntervalBound {
              bound_type: Finite(1),
              is_inclusive: True,
            },
            upper_bound: IntervalBound {
              bound_type: Finite(10),
              is_inclusive: True,
            },
          },
          pairs: [Pair(1, (2, 2)), Pair(1, (5, 5))],
          list_items: [
            ([10, 12, 13, 14], ["aa", "bb", "cc", "dd"]),
            ([21, 22, 23, 24], ["ba", "bb", "bc", "bd"]),
          ],
        },
      ),
      nest2: First(None),
      some_tuple: Some((19, 20)),
      none: None,
      dict2: dict.empty
        |> dict.insert("v1", [(1, "s1"), (2, "s2")])
        |> dict.insert("v4", [(10, "s11"), (22, "s2")]),
    }

  expect [Pair(_key, expect_data)] = get_data_with_idx(datum, [76])
  expect_data == [#"ec5a9f9bb81ca16b05a0dedbb47a51ca7e0d09ae88a0fc221e549cf8"]
}

// Minswap V1
type OrderDatumMinswapV1 {
  sender: Address,
  receiver: Address,
  receiver_datum_hash: Option<ByteArray>,
  step: OrderStepMinswapV1,
  batcher_fee: Int,
  deposit_ada: Int,
}

type OrderStepMinswapV1 {
  SwapExactIn { desired_asset: (Asset, Int), min_receive: Int }
}

test success_get_data_with_idx_when_minswap_v1() {
  let datum =
    OrderDatumMinswapV1 {
      sender: address.from_script("sender"),
      receiver: address.from_script("receiver"),
      receiver_datum_hash: None,
      step: SwapExactIn {
        desired_asset: (Asset("pid", "name"), 100),
        min_receive: 2_000_000,
      },
      batcher_fee: 1_000_000,
      deposit_ada: 100_000_000,
    }
  expect [
    //
    Pair(_, sender),
    // 
    Pair(_, receiver),
    //
    Pair(_, desired_asset_pid),
    // 
    Pair(_, desired_asset_name),
  ] = get_data_with_idx(datum, [11, 12, 22, 29])
  and {
    sender == ["sender"],
    receiver == ["receiver"],
    desired_asset_pid == ["pid"],
    desired_asset_name == ["name"],
  }
}

// Minswap V2
type OrderDatumMinswapV2 {
  canceller: Validator,
  refund_address: Address,
  refund_datum: ExtraOrderDatum,
  receiver_address: Address,
  receiver_datum: ExtraOrderDatum,
  lp_asset: Asset,
  step: OrderStepMinswapV2,
  max_batcher_fee: Int,
  expire_options: Option<Int>,
}

type Validator {
  KeySignature { pub_key_hash: PublicKeyHash }
}

type ExtraOrderDatum {
  EODNoDatum
}

type Asset {
  policy_id: PolicyId,
  asset_name: AssetName,
}

type OrderStepMinswapV2 {
  SwapExactInMinswapV2 {
    direction: Bool,
    swap_amount_option: SwapAmountOption,
    min_receive: Int,
    killable: Bool,
  }
  StopLoss {
    direction: Bool,
    swap_amount_option: SwapAmountOption,
    stop_loss_receive: Int,
  }
  OCO {
    direction: Bool,
    swap_amount_option: SwapAmountOption,
    min_receive: Int,
    stop_loss_receive: Int,
  }
  SwapExactOut {
    direction: Bool,
    swap_amount_option: SwapAmountOption,
    expected_receive: Int,
    killable: Bool,
  }
  PartialSwap {
    direction: Bool,
    total_swap_amount: Int,
    price_ratio_numerator: Int,
    price_ratio_denominator: Int,
    hops: Int,
    min_receive_per_swap: Int,
    max_batcher_fee_per_swap: Int,
  }
  SwapMultiRouting {
    routings: List<(Asset, Int)>,
    swap_amount_option: SwapAmountOption,
    min_receive: Int,
  }
}

type SwapAmountOption {
  SpecificAmount { swap_amount: Int }
}

test success_get_data_with_idx_when_minswap_v2() {
  let datum =
    OrderDatumMinswapV2 {
      canceller: KeySignature("sign"),
      refund_address: address.from_script("refund"),
      refund_datum: EODNoDatum,
      receiver_address: address.from_script("receiver"),
      receiver_datum: EODNoDatum,
      lp_asset: Asset("pid", "name"),
      step: SwapExactInMinswapV2 {
        direction: True,
        swap_amount_option: SpecificAmount(100_000_000),
        min_receive: 2_000_000,
        killable: False,
      },
      max_batcher_fee: 1_000_000,
      expire_options: None,
    }
  expect [
    //
    Pair(_, sender),
    // 
    Pair(_, receiver),
    // 
    Pair(_, lp_pid),
    //
    Pair(_, lp_name),
  ] = get_data_with_idx(datum, [18, 19, 28, 37])
  and {
    sender == ["refund"],
    receiver == ["receiver"],
    lp_pid == ["pid"],
    lp_name == ["name"],
  }
}

test success_flatten_dt_when_complex_structure() {
  let datum =
    DatumTest {
      dict: dict.empty
        |> dict.insert(
            "123",
            dict.empty
              |> dict.insert("s1", 0)
              |> dict.insert("s2", 1),
          )
        |> dict.insert(
            "1234",
            dict.empty
              |> dict.insert("s5", 0)
              |> dict.insert("s6", 5),
          ),
      int: 90000000,
      tuple: (10, 8, 1, 1),
      bytearray: #"c03bf2bd26327637e1910410a363cca092d89d5b6a89641602dcc268",
      list: [809, 1000],
      tuple_tuple: (
        (8442487033, 4503599627370496),
        (21817265503, 10000000000000000),
        (15427053409, 125000000000000),
        (9, 10),
      ),
      some: Some(#"d87980"),
      vkh: VerificationKey(
        #"ec5a9f9bb81ca16b05a0dedbb47a51ca7e0d09ae88a0fc221e549cf8",
      ),
      skh: Some(
        Inline(
          VerificationKey(
            #"ec5a9f9bb81ca16b05a0dedbb47a51ca7e0d09ae88a0fc221e549cf8",
          ),
        ),
      ),
      addr: address.from_script("script")
        |> address.with_delegation_script("stake"),
      nest: Second(
        Thirdly {
          interval: Interval {
            lower_bound: IntervalBound {
              bound_type: Finite(1),
              is_inclusive: True,
            },
            upper_bound: IntervalBound {
              bound_type: Finite(10),
              is_inclusive: True,
            },
          },
          pairs: [Pair(1, (2, 2)), Pair(1, (5, 5))],
          list_items: [
            ([10, 12, 13, 14], ["aa", "bb", "cc", "dd"]),
            ([21, 22, 23, 24], ["ba", "bb", "bc", "bd"]),
          ],
        },
      ),
      nest2: First(None),
      some_tuple: Some((19, 20)),
      none: None,
      dict2: dict.empty
        |> dict.insert("v1", [(1, "s1"), (2, "s2")])
        |> dict.insert("v4", [(10, "s11"), (22, "s2")]),
    }

  let (flattened, _) = flatten_dt(datum)
  // trace flattened
  pairs.get_last(flattened, 76) == Some(
    #"ec5a9f9bb81ca16b05a0dedbb47a51ca7e0d09ae88a0fc221e549cf8",
  )
}

test success_flatten_dt_when_minswap_v1() {
  let datum =
    OrderDatumMinswapV1 {
      sender: address.from_script("sender"),
      receiver: address.from_script("receiver"),
      receiver_datum_hash: None,
      step: SwapExactIn {
        desired_asset: (Asset("pid", "name"), 100),
        min_receive: 2_000_000,
      },
      batcher_fee: 1_000_000,
      deposit_ada: 100_000_000,
    }
  let (flattened, _) = flatten_dt(datum)
  // trace flattened
  let expected =
    [
      Pair(12, "pid"), Pair(11, "name"), Pair(22, "receiver"),
      Pair(29, "sender"),
    ]
  pairs.foldl(
    expected,
    True,
    fn(k, v, is_valid) {
      and {
        is_valid,
        when pairs.get_last(flattened, k) is {
          None -> fail @""
          Some(b) -> b == v
        },
      }
    },
  )
}

test success_flatten_dt_when_minswap_v2_swap_in() {
  let datum =
    OrderDatumMinswapV2 {
      canceller: KeySignature("sign"),
      refund_address: address.from_script("refund"),
      refund_datum: EODNoDatum,
      receiver_address: address.from_script("receiver"),
      receiver_datum: EODNoDatum,
      lp_asset: Asset("pid", "name"),
      step: SwapExactInMinswapV2 {
        direction: True,
        swap_amount_option: SpecificAmount(100_000_000),
        min_receive: 2_000_000,
        killable: False,
      },
      max_batcher_fee: 1_000_000,
      expire_options: None,
    }
  let (flattened, _) = flatten_dt(datum)
  // trace flattened
  let expected =
    [
      Pair(18, "name"), Pair(19, "pid"), Pair(28, "receiver"),
      Pair(37, "refund"),
    ]
  pairs.foldl(
    expected,
    True,
    fn(k, v, is_valid) {
      and {
        is_valid,
        when pairs.get_last(flattened, k) is {
          None -> fail @""
          Some(b) -> b == v
        },
      }
    },
  )
}

test success_flatten_dt_when_minswap_v2_stop_loss() {
  let datum =
    OrderDatumMinswapV2 {
      canceller: KeySignature("sign"),
      refund_address: address.from_script("refund"),
      refund_datum: EODNoDatum,
      receiver_address: address.from_script("receiver"),
      receiver_datum: EODNoDatum,
      lp_asset: Asset("pid", "name"),
      step: StopLoss {
        direction: True,
        swap_amount_option: SpecificAmount(100_000_000),
        stop_loss_receive: 2_000_000,
      },
      max_batcher_fee: 1_000_000,
      expire_options: None,
    }
  let (flattened, _) = flatten_dt(datum)
  // trace flattened
  let expected =
    [
      Pair(16, "name"), Pair(17, "pid"), Pair(26, "receiver"),
      Pair(35, "refund"),
    ]
  pairs.foldl(
    expected,
    True,
    fn(k, v, is_valid) {
      and {
        is_valid,
        when pairs.get_last(flattened, k) is {
          None -> fail @""
          Some(b) -> b == v
        },
      }
    },
  )
}

test success_flatten_dt_when_minswap_v2_oco() {
  let datum =
    OrderDatumMinswapV2 {
      canceller: KeySignature("sign"),
      refund_address: address.from_script("refund"),
      refund_datum: EODNoDatum,
      receiver_address: address.from_script("receiver"),
      receiver_datum: EODNoDatum,
      lp_asset: Asset("pid", "name"),
      step: OCO {
        direction: True,
        swap_amount_option: SpecificAmount(100_000_000),
        min_receive: 2_000_000,
        stop_loss_receive: 1_000_000,
      },
      max_batcher_fee: 1_000_000,
      expire_options: None,
    }
  let (flattened, _) = flatten_dt(datum)
  // trace flattened
  let expected =
    [
      Pair(17, "name"), Pair(18, "pid"), Pair(27, "receiver"),
      Pair(36, "refund"),
    ]
  pairs.foldl(
    expected,
    True,
    fn(k, v, is_valid) {
      and {
        is_valid,
        when pairs.get_last(flattened, k) is {
          None -> fail @""
          Some(b) -> b == v
        },
      }
    },
  )
}

test success_flatten_dt_when_minswap_v2_swap_out() {
  let datum =
    OrderDatumMinswapV2 {
      canceller: KeySignature("sign"),
      refund_address: address.from_script("refund"),
      refund_datum: EODNoDatum,
      receiver_address: address.from_script("receiver"),
      receiver_datum: EODNoDatum,
      lp_asset: Asset("pid", "name"),
      step: SwapExactOut {
        direction: True,
        swap_amount_option: SpecificAmount(100_000_000),
        expected_receive: 2_000_000,
        killable: False,
      },
      max_batcher_fee: 1_000_000,
      expire_options: None,
    }
  let (flattened, _) = flatten_dt(datum)
  // trace flattened
  let expected =
    [
      Pair(18, "name"), Pair(19, "pid"), Pair(28, "receiver"),
      Pair(37, "refund"),
    ]
  pairs.foldl(
    expected,
    True,
    fn(k, v, is_valid) {
      and {
        is_valid,
        when pairs.get_last(flattened, k) is {
          None -> fail @""
          Some(b) -> b == v
        },
      }
    },
  )
}

test success_flatten_dt_when_minswap_v2_partial_swap() {
  let datum =
    OrderDatumMinswapV2 {
      canceller: KeySignature("sign"),
      refund_address: address.from_script("refund"),
      refund_datum: EODNoDatum,
      receiver_address: address.from_script("receiver"),
      receiver_datum: EODNoDatum,
      lp_asset: Asset("pid", "name"),
      step: PartialSwap {
        direction: True,
        total_swap_amount: 100_000_000,
        price_ratio_numerator: 123_000_000,
        price_ratio_denominator: 123_000_000,
        hops: 2_000_000,
        min_receive_per_swap: 2_000_000,
        max_batcher_fee_per_swap: 5_000_000,
      },
      max_batcher_fee: 1_000_000,
      expire_options: None,
    }
  let (flattened, _) = flatten_dt(datum)
  // trace flattened
  let expected =
    [
      Pair(18, "name"), Pair(19, "pid"), Pair(28, "receiver"),
      Pair(37, "refund"),
    ]
  pairs.foldl(
    expected,
    True,
    fn(k, v, is_valid) {
      and {
        is_valid,
        when pairs.get_last(flattened, k) is {
          None -> fail @""
          Some(b) -> b == v
        },
      }
    },
  )
}

test success_flatten_dt_when_minswap_v2_swap_multi_routing() {
  let datum =
    OrderDatumMinswapV2 {
      canceller: KeySignature("sign"),
      refund_address: address.from_script("refund"),
      refund_datum: EODNoDatum,
      receiver_address: address.from_script("receiver"),
      receiver_datum: EODNoDatum,
      lp_asset: Asset("pid", "name"),
      step: SwapMultiRouting {
        routings: [(Asset("pid", "name"), 12)],
        swap_amount_option: SpecificAmount(100_000_000),
        min_receive: 2_000_000,
      },
      max_batcher_fee: 1_000_000,
      expire_options: None,
    }
  let (flattened, _) = flatten_dt(datum)
  // trace flattened
  let expected =
    [
      Pair(16, "name"), Pair(17, "pid"), Pair(32, "receiver"),
      Pair(41, "refund"),
    ]
  pairs.foldl(
    expected,
    True,
    fn(k, v, is_valid) {
      and {
        is_valid,
        when pairs.get_last(flattened, k) is {
          None -> fail @""
          Some(b) -> b == v
        },
      }
    },
  )
}

type BidLimitMulti {
  owner_vk: PublicKeyHash,
  owner_sk: Option<PublicKeyHash>,
  from_epoch: Int,
  to_epoch: Int,
  quantity: Int,
  requested_yield: Int,
  bond_types: List<BondType>,
}

type BondType {
  DanogoBond
  OptimBond
}

type AskLimit {
  owner_vk: PublicKeyHash,
  owner_sk: Option<PublicKeyHash>,
  requested_yield: Int,
}

type EscrowDatum {
  epo_rewards: PValue,
  duration: Int,
  bond_symbol: PolicyId,
  token_name: AssetName,
  bond_amount: Int,
  buffer: Int,
  otm_fee: Int,
  og_lender: ByteArray,
  start: Int,
}

test success_flatten_dt_when_bid() {
  let datum =
    BidLimitMulti {
      owner_vk: "owner_vk",
      owner_sk: None,
      from_epoch: 444,
      to_epoch: 445,
      quantity: 10,
      requested_yield: 500,
      bond_types: [OptimBond, DanogoBond],
    }
  let (flattened, _) = flatten_dt(datum)
  // trace flattened
  and {
    pairs.get_last(flattened, 13) == Some("owner_vk"),
    pairs.get_last(flattened, 11) == Some(#"313232"),
  }
}

test success_flatten_dt_when_ask() {
  let datum =
    AskLimit { owner_vk: "owner_vk", owner_sk: None, requested_yield: 500 }
  let (flattened, _) = flatten_dt(datum)
  // trace flattened
  and {
    pairs.get_last(flattened, 6) == Some("owner_vk"),
    pairs.get_last(flattened, 4) == Some(#"313232"),
  }
}

test success_flatten_dt_when_bond() {
  let datum =
    EscrowDatum {
      epo_rewards: [Pair("pid", [Pair("name", 100_000_000)])],
      duration: 44,
      bond_symbol: "pid",
      token_name: "name",
      bond_amount: 10,
      buffer: 44,
      otm_fee: 44,
      og_lender: "og_lender",
      start: 444,
    }

  let (flattened, _) = flatten_dt(datum)
  // trace flattened
  and {
    pairs.get_last(flattened, 9) == Some("pid"),
    pairs.get_last(flattened, 8) == Some("name"),
  }
}
