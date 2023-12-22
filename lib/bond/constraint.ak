use aiken/dict
use aiken/list
use aiken/math
use aiken/transaction.{Input}
use aiken/transaction/credential.{ScriptCredential}
use aiken/transaction/value
use bond/types.{
  AskLimit, AskMaking, BidLimit, BidLimitMulti, BidMaking, BondConfig,
  ConfigLimit, ConfigMaking,
}
use common/time.{Basis, BasisPoints, EpochTime}

pub fn get_escrow_ref(ref_inputs: List<Input>, cfg: BondConfig) -> Option<Input> {
  list.find(
    ref_inputs,
    fn(i) {
      when i.output.address.payment_credential is {
        ScriptCredential(k) -> and {
            k == cfg.escrow_payment_key,
            when
              dict.values(value.tokens(i.output.value, cfg.escrow_policy_id))
            is {
              [q] if q > 0 -> True
              _ -> False
            },
          }
        _ -> False
      }
    },
  )
}

pub fn yield_limit_valid(conf: ConfigLimit, val: Basis) -> Bool {
  (math.clamp(val, conf.bond.basis_points_min, conf.bond.basis_points_max) == val)?
}

pub fn yield_making_valid(conf: ConfigMaking, val: Basis) -> Bool {
  (math.clamp(val, conf.bond.basis_points_min, conf.bond.basis_points_max) == val)?
}

pub fn epoch_valid(epo_from: EpochTime, epo_to: EpochTime, out_qty: Int) -> Bool {
  and {
    (epo_to >= epo_from)?,
    (out_qty > 0)?,
  }
}

pub fn ask_limit_valid(left: AskLimit, right: AskLimit) -> Bool {
  and {
    (left.owner_vk == right.owner_vk)?,
    (left.owner_sk == right.owner_sk)?,
    (left.requested_yield == right.requested_yield)?,
  }
}

pub fn bid_limit_valid(left: BidLimit, right: BidLimit) -> Bool {
  and {
    (left.owner_vk == right.owner_vk)?,
    (left.owner_sk == right.owner_sk)?,
    (left.from_epoch == right.from_epoch)?,
    (left.to_epoch == right.to_epoch)?,
    (left.requested_yield == right.requested_yield)?,
  }
}

pub fn ask_making_valid(left: AskMaking, right: AskMaking) -> Bool {
  and {
    (left.owner_vk == right.owner_vk)?,
    (left.owner_sk == right.owner_sk)?,
    (left.requested_yield == right.requested_yield)?,
    (left.bid_sc == right.bid_sc)?,
    (left.margin == right.margin)?,
  }
}

pub fn bid_making_valid(left: BidMaking, right: BidMaking) -> Bool {
  and {
    (left.owner_vk == right.owner_vk)?,
    (left.owner_sk == right.owner_sk)?,
    (left.from_epoch == right.from_epoch)?,
    (left.to_epoch == right.to_epoch)?,
    (left.requested_yield == right.requested_yield)?,
    (left.ask_sc == right.ask_sc)?,
    (left.margin == right.margin)?,
  }
}

pub fn yield_valid(basis: BasisPoints, v: Int) -> Bool {
  (math.clamp(v, basis.min, basis.max) == v)?
}

pub fn bid_limit_multi_valid(left: BidLimitMulti, right: BidLimitMulti) -> Bool {
  and {
    (left.owner_vk == right.owner_vk)?,
    (left.owner_sk == right.owner_sk)?,
    (left.from_epoch == right.from_epoch)?,
    (left.to_epoch == right.to_epoch)?,
    (left.requested_yield == right.requested_yield)?,
    (list.difference(left.bond_types, right.bond_types) == [])?,
  }
}
