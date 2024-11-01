use aiken/collection/dict.{Dict}
use aiken/crypto.{
  Blake2b_224, Blake2b_256, DataHash, Hash, ScriptHash, VerificationKeyHash,
}
use cardano/assets.{AssetName, PolicyId}
use cardano/transaction.{Redeemer, ScriptPurpose}

pub type Redeemers =
  Pairs<ScriptPurpose, Redeemer>

pub type PublicKeyHash =
  VerificationKeyHash

pub type Blake2b224Hash =
  Hash<Blake2b_224, ByteArray>

pub type Blake2b256Hash =
  Hash<Blake2b_256, ByteArray>

pub type TupleAsset =
  (PolicyId, AssetName)

pub type ScriptKeyHash =
  ScriptHash

pub type Datums =
  Dict<DataHash, Data>

pub type AssetUnit =
  String

pub type Result<a, b> {
  OK(a)
  Error(b)
}

pub type PosixTime =
  Int

pub type Basis =
  Int

pub type Asset {
  policy_id: PolicyId,
  asset_name: AssetName,
}

// danh sách các token được cho phép trong giao dịch theo mỗi defi
pub type WhitelistAsset =
  Pairs<PolicyId, Pairs<AssetName, List<Asset>>>

// enum xác định cần kiểm tra thông tin datum như thế nào
pub type FieldValidation {
  Dynamic { flag: ByteArray }
  // dynamic data
  DynamicAsset {
    flag_name: ByteArray,
    flag_policy_id: (Int, ByteArray),
    validate_asset: Bool,
  }
  // flag_name: (index of name, flag)
  WhenIs { case: Dict<ByteArray, FieldIndexIdentifier> }
  Ref { validation: FieldIndexIdentifier }
}

// chưa dùng đến
//ContainsList { expect: List<ByteArray> },
//ByteArrayEqualTo { expect: ByteArray }, // bytearray == bytearray
//TupleEqualTo { expect: List<ByteArray> }, // tuple == tuple
//TupleOrdinal { expect: ByteArray, ordinal: Int, length: Int }, // ordinal of tuple bytearray
// danh sách index tương ứng với rule cần kiểm tra
pub type FieldIndexIdentifier =
  Pairs<Int, FieldValidation>

// danh sách các script hash được phép trong giao dịch và rule kiểm tra 1 số thông tin trong datum tương ứng
pub type AllowScriptHash =
  Pairs<ScriptKeyHash, FieldIndexIdentifier>

test blabla() {
  let a: AllowScriptHash =
    [
      Pair(
        "minswap_skh_v2",
        [
          Pair(
            6,
            Ref(
              [
                // desired_asset
                Pair(
                  11,
                  DynamicAsset(
                    #"61737365745f6e616d65",
                    (12, #"61737365745f706f6c6963795f6964"),
                    False,
                  ),
                ),
                // receiver_skh
                Pair(24, Dynamic(#"626174636865725f73746b68")),
                // flag batcher_skh
                // receiver_vkh    
                Pair(27, Dynamic(#"626174636865725f766b68")),
                // flag batcher_vkh
                // sender_skh     
                Pair(36, Dynamic(#"626174636865725f73746b68")),
                // flag batcher_skh
                // sender_vkh
                Pair(39, Dynamic(#"626174636865725f766b68")),
              ],
            ),
          ),
          // flag batcher_vkh
          Pair(
            6,
            WhenIs(
              dict.empty
                |> dict.insert(
                    #"313231",
                    [
                      // lp_asset
                      Pair(
                        18,
                        DynamicAsset(
                          #"61737365745f6e616d65",
                          (19, #"61737365745f706f6c6963795f6964"),
                          False,
                        ),
                      ),
                      // receiver_skh
                      Pair(30, Dynamic(#"626174636865725f73746b68")),
                      // flag batcher_skh
                      // receiver_vkh    
                      Pair(33, Dynamic(#"626174636865725f766b68")),
                      // flag batcher_vkh
                      // refund_skh     
                      Pair(44, Dynamic(#"626174636865725f73746b68")),
                      // flag batcher_skh
                      // refund_vkh
                      Pair(47, Dynamic(#"626174636865725f766b68")),
                      // flag batcher_vkh
                      // canceller
                      Pair(50, Dynamic(#"626174636865725f766b68")),
                    ],
                  ) // flag batcher_vkh
                // Stop Loss
                
              |> dict.insert(
                    #"313232",
                    [
                      // lp_asset
                      Pair(
                        16,
                        DynamicAsset(
                          #"61737365745f6e616d65",
                          (17, #"61737365745f706f6c6963795f6964"),
                          False,
                        ),
                      ),
                      // receiver_skh
                      Pair(28, Dynamic(#"626174636865725f73746b68")),
                      // flag batcher_skh
                      // receiver_vkh    
                      Pair(31, Dynamic(#"626174636865725f766b68")),
                      // flag batcher_vkh
                      // refund_skh     
                      Pair(42, Dynamic(#"626174636865725f73746b68")),
                      // flag batcher_skh
                      // refund_vkh
                      Pair(45, Dynamic(#"626174636865725f766b68")),
                      // flag batcher_vkh
                      // canceller
                      Pair(48, Dynamic(#"626174636865725f766b68")),
                    ],
                  ) // flag batcher_vkh
                // OCO
                
              |> dict.insert(
                    #"313233",
                    [
                      // lp_asset
                      Pair(
                        17,
                        DynamicAsset(
                          #"61737365745f6e616d65",
                          (18, #"61737365745f706f6c6963795f6964"),
                          False,
                        ),
                      ),
                      // receiver_skh
                      Pair(29, Dynamic(#"626174636865725f73746b68")),
                      // flag batcher_skh
                      // receiver_vkh    
                      Pair(32, Dynamic(#"626174636865725f766b68")),
                      // flag batcher_vkh
                      // refund_skh     
                      Pair(43, Dynamic(#"626174636865725f73746b68")),
                      // flag batcher_skh
                      // refund_vkh
                      Pair(46, Dynamic(#"626174636865725f766b68")),
                      // flag batcher_vkh
                      // canceller
                      Pair(49, Dynamic(#"626174636865725f766b68")),
                    ],
                  ) // flag batcher_vkh
                // SwapExactOut
                
              |> dict.insert(
                    #"313234",
                    [
                      // lp_asset
                      Pair(
                        18,
                        DynamicAsset(
                          #"61737365745f6e616d65",
                          (19, #"61737365745f706f6c6963795f6964"),
                          False,
                        ),
                      ),
                      // receiver_skh
                      Pair(30, Dynamic(#"626174636865725f73746b68")),
                      // flag batcher_skh
                      // receiver_vkh    
                      Pair(33, Dynamic(#"626174636865725f766b68")),
                      // flag batcher_vkh
                      // refund_skh     
                      Pair(44, Dynamic(#"626174636865725f73746b68")),
                      // flag batcher_skh
                      // refund_vkh
                      Pair(47, Dynamic(#"626174636865725f766b68")),
                      // flag batcher_vkh
                      // canceller
                      Pair(50, Dynamic(#"626174636865725f766b68")),
                    ],
                  ) // flag batcher_vkh
                // Partial Swap
                
              |> dict.insert(
                    #"313235",
                    [
                      // lp_asset
                      Pair(
                        18,
                        DynamicAsset(
                          #"61737365745f6e616d65",
                          (19, #"61737365745f706f6c6963795f6964"),
                          False,
                        ),
                      ),
                      // receiver_skh
                      Pair(30, Dynamic(#"626174636865725f73746b68")),
                      // flag batcher_skh
                      // receiver_vkh    
                      Pair(33, Dynamic(#"626174636865725f766b68")),
                      // flag batcher_vkh
                      // refund_skh     
                      Pair(44, Dynamic(#"626174636865725f73746b68")),
                      // flag batcher_skh
                      // refund_vkh
                      Pair(47, Dynamic(#"626174636865725f766b68")),
                      // flag batcher_vkh
                      // canceller
                      Pair(50, Dynamic(#"626174636865725f766b68")),
                    ],
                  ) // flag batcher_vkh
                // Swap Multi Routing
                
              |> dict.insert(
                    #"313236",
                    [
                      // lp_asset
                      Pair(
                        22,
                        DynamicAsset(
                          #"61737365745f6e616d65",
                          (23, #"61737365745f706f6c6963795f6964"),
                          False,
                        ),
                      ),
                      // receiver_skh
                      Pair(34, Dynamic(#"626174636865725f73746b68")),
                      // flag batcher_skh
                      // receiver_vkh    
                      Pair(37, Dynamic(#"626174636865725f766b68")),
                      // flag batcher_vkh
                      // refund_skh     
                      Pair(48, Dynamic(#"626174636865725f73746b68")),
                      // flag batcher_skh
                      // refund_vkh
                      Pair(51, Dynamic(#"626174636865725f766b68")),
                      // flag batcher_vkh
                      // canceller
                      Pair(54, Dynamic(#"626174636865725f766b68")),
                    ],
                  ),
            ),
          ),
        ],
      ),
    ]
  // SwapExactIn
  trace a
  // flag batcher_vkh
  True
}
