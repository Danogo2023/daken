use club/danogo_feed/constants

pub type DanogoFeedToken {
  GovernanceToken
  PriceFeedToken
  StakeKeyToken
  UnknownFeedToken
}

pub fn find_feed_token_type_from_name(name: ByteArray) -> DanogoFeedToken {
  if name == constants.governance_token_name {
    GovernanceToken
  } else if name == constants.price_feed_token_name {
    PriceFeedToken
  } else if name == constants.stake_key_token_name {
    StakeKeyToken
  } else {
    UnknownFeedToken
  }
}

test name_converting_test1() {
  find_feed_token_type_from_name("gDGC") == GovernanceToken
}

test name_converting_test2() {
  find_feed_token_type_from_name("pDGC") == PriceFeedToken
}

test name_converting_test3() {
  find_feed_token_type_from_name("sDGC") == StakeKeyToken
}

test name_converting_test4() {
  find_feed_token_type_from_name("unknown") == UnknownFeedToken
}
