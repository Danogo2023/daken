use aiken/collection/dict
use aiken/crypto
use cardano/assets.{PolicyId}
use cardano/transaction.{Transaction}
use daken/inputs_hash

validator lock_forever {
  mint(_rdmr: Data, pid: PolicyId, transaction: Transaction) {
    // - Mint:
    //    - NFT protocol (require):
    //      - nft_name: must be blake2b_256 hash all inputs
    //      - quantity: should be 1
    //    - NFT license (optional):
    //      - nft_license_name: must be hash blake2b_256 nft_name
    //      - quantity: should be 1
    let Transaction { inputs, mint, .. } = transaction
    let nft_name = inputs_hash.blake2b_256_sort_asc(inputs)
    let (has_protocol_nft, is_valid_nft_qty) =
      dict.foldl(
        assets.tokens(mint, pid),
        (False, True),
        fn(name, qty, (seen_has_protocol_nft, is_valid_nft_qty)) {
          let is_valid_nft_qty = is_valid_nft_qty && qty == 1

          let has_protocol_nft =
            if name == nft_name {
              // required
              True
            } else if name == crypto.blake2b_256(nft_name) {
              // optional
              seen_has_protocol_nft
            } else {
              fail @"mint nft is invalid"
            }
          (has_protocol_nft, is_valid_nft_qty)
        },
      )
    and {
      has_protocol_nft?,
      is_valid_nft_qty?,
    }
  }

  else(_) {
    fail @"lock forever"
  }
}
