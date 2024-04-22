//// This module provides the currently redemmers.
////

/// (Club Policy) Club Create
pub const club_create = 1

/// (Club Policy) Club Close
pub const club_close = 2

/// (Club Policy) Deposit Create With State
pub const deposit_create_with_state = 4

/// (Club Policy) Deposit Update
pub const deposit_update = 5

/// (Club Policy) Deposit Convert
pub const deposit_convert = 6

/// (Club Policy) Withdraw Create With State
pub const withdraw_create_with_state = 7

/// (Club Policy) Withdraw Update
pub const withdraw_update = 8

/// (Club Policy) Withdraw Redeem
pub const withdraw_redeem = 9

/// (Club Policy) Calculate NAV
pub const calculate_nav = 10

/// (Club Policy) Club Redeem (burn op token)
pub const club_redeem = 11

/// (Club Policy) Platform Garbage Collect
pub const platform_garbage_collect = 12

/// (General State) General State Update
pub const general_state_update = 13

/// (General State) General State Close
pub const general_state_close = 14

/// (General State) General State Platform Garbage Collect
pub const general_state_platform_garbage_collect = 15

/// (General State) General State Upgrade Version
pub const general_state_upgrade_version = 16

/// (Trading State) Trading State Update
pub const trading_state_update = 17

/// (Trading State) Trading State Close
pub const trading_state_close = 18

/// (Trading State) Trading State Liquidation
pub const trading_state_liquidation = 19

/// (Trading State) Trading State Staking Delegate
pub const trading_state_staking = 21

/// (Trading State) Trading State Calc NAV
pub const trading_state_calc_nav = 22

/// (Trading State) Trading State Platform Garbage Collect
pub const trading_state_platform_garbage_collect = 23

/// (Trading State) Trading State Upgrade Version
pub const trading_state_upgrade_version = 24

/// (Deposit State) Deposit State Create Request
pub const deposit_state_create_request = 25

/// (Deposit State) Deposit State Calc NAV
pub const deposit_state_calc_nav = 26

/// (Deposit State) Deposit State Close
pub const deposit_state_close = 27

/// (Deposit State) Deposit State Platform Garbage Collect
pub const deposit_state_platform_garbage_collect = 28

/// (Deposit State) Deposit State Upgrade Version
pub const deposit_state_upgrade_version = 29

/// (Deposit Pool) Deposit Pool Create Request
pub const deposit_pool_create_request = 30

/// (Deposit Pool) Deposit Pool Update Request
pub const deposit_pool_update_request = 31

/// (Deposit Pool) Deposit Pool Calc NAV
pub const deposit_pool_calc_nav = 32

/// (Deposit Pool) Deposit Pool Convert
pub const deposit_pool_convert = 33

/// (Deposit Pool) Deposit Pool System Collect
pub const deposit_pool_system_collect = 34

/// (Deposit Pool) Deposit Pool Platform Garbage Collect
pub const deposit_pool_platform_garbage_collect = 35

/// (Deposit Pool) Deposit Pool Upgrade Version
pub const deposit_pool_upgrade_version = 36

/// (Withdraw State) Withdraw State Create Request
pub const withdraw_state_create_request = 37

/// (Withdraw State) Withdraw State Calc NAV
pub const withdraw_state_calc_nav = 38

/// (Withdraw State) Withdraw State Close
pub const withdraw_state_close = 39

/// (Withdraw State) Withdraw State Platform Garbage Collect
pub const withdraw_state_platform_garbage_collect = 41

/// (Withdraw State) Withdraw State Upgrade Version
pub const withdraw_state_upgrade_version = 42

/// (Withdraw Pool) Withdraw Pool Create Request
pub const withdraw_pool_create_request = 43

/// (Withdraw Pool) Withdraw Pool Update Request
pub const withdraw_pool_update_request = 44

/// (Withdraw Pool) Withdraw Pool Calc NAV
pub const withdraw_pool_calc_nav = 45

/// (Withdraw Pool) Withdraw Pool Redeem
pub const withdraw_pool_redeem = 46

/// (Withdraw Pool) Withdraw Pool System Collect
pub const withdraw_pool_system_collect = 47

/// (Withdraw Pool) Withdraw Pool Platform Garbage Collect
pub const withdraw_pool_platform_garbage_collect = 48

/// (Withdraw Pool) Withdraw Pool Upgrade Version
pub const withdraw_pool_upgrade_version = 49

/// (NAV State) NAV State Calc
pub const nav_state_calc = 50

/// (NAV State) NAV State Close
pub const nav_state_close = 51

/// (NAV State) NAV State Force
pub const nav_state_force = 52

/// (NAV State) NAV State Platform Garbage Collect
pub const nav_state_platform_garbage_collect = 53

/// (NAV State) NAV State Upgrade Version
pub const nav_state_upgrade_version = 54

/// (Redeem Pool) User Redeem (for operator/member)
pub const user_redeem = 55

/// (Redeem Pool) Redeem Pool Platform Garbage Collect
pub const redeem_pool_platform_garbage_collect = 56

/// (Redeem Pool) Redeemer Pool Upgrade Version
pub const redeemer_pool_upgrade_version = 57

/// (Vault State) Vault State Calc NAV
pub const vault_state_calc_nav = 58

/// (Vault State) Vault State Calc NAV
pub const vault_state_close = 59

/// (Vault State) Vault State Upgrade Version
pub const vault_state_upgrade_version = 60

/// (Vault State) Vault State Platform Garbage Collect
pub const vault_state_platform_garbage_collect = 61

/// (Vault State) Vault State Staking Delegate
pub const vault_state_staking = 62

/// (Vault State) Vault State Invest Danogo Bond Ask Limit
pub const vault_state_invest_danogo_bond_ask_limit = 63

/// (Vault State) Vault State Invest Danogo Bond Ask Making
pub const vault_state_invest_danogo_bond_ask_making = 64

/// (Vault State) Vault State Invest Danogo Bond Bid Limit
pub const vault_state_invest_danogo_bond_bid_limit = 65

/// (Vault State) Vault State Invest Danogo Bond Bid Making
pub const vault_state_invest_danogo_bond_bid_making = 66

/// (Vault Asset) Vault Asset Platform Garbage Collect
pub const vault_asset_platform_garbage_collect = 67

/// (Deposit State) Deposit Update
pub const deposit_state_update = 68

/// (Operator Fee) Operator Fee Op Claim
pub const operator_fee_op_claim = 69

/// (Withdraw Pool) Withdraw Pool Club Close
pub const withdraw_pool_close = 70

/// (Operator Fee) Operator Fee System Force Redeem
pub const operator_fee_system_force_redeem = 71

/// (Club Policy) Deposit Create With Pool
pub const deposit_create_with_pool = 72

/// (Club Policy) System Force Redeem
pub const system_force_redeem = 73

/// (Club Policy) Withdraw Create With Pool
pub const withdraw_create_with_pool = 75

/// (Club Policy) Deposit Pool Cancel
pub const deposit_pool_cancel = 77

/// (Operator Fee) Operator Fee Calc NAV
pub const operator_fee_calc_nav = 78

/// (Withdraw State) Withdraw Update
pub const withdraw_state_update = 79

/// (Club Policy) Force Close when LIQUIDATED
pub const club_force_close_when_liquidated = 80

/// (Trading State) Trading State Force Close when LIQUIDATED
pub const trading_state_force_close_when_liquidated = 81

/// (Nav State) Nav State Force Close when LIQUIDATED
pub const nav_state_force_close_when_liquidated = 82

/// (Withdraw State) Withdraw State Force Close when LIQUIDATED
pub const withdraw_state_force_close_when_liquidated = 83

/// (Withdraw Pool) Withdraw Pool Force Close when LIQUIDATED
pub const withdraw_pool_force_close_when_liquidated = 84

/// (Vault State) Vault State Force Close when LIQUIDATED
pub const vault_state_force_close_when_liquidated = 85

/// (Operator Fee) Operator Fee Force Close when LIQUIDATED
pub const operator_fee_force_close_when_liquidated = 86

/// (Club Policy) Club Staking Delegate
pub const policy_club_delegate = 87

/// (Vault State) Club Staking Withdraw
pub const vault_state_club_withdraw = 88

/// (Trading State) Club Staking Withdraw
pub const trading_state_club_withdraw = 89

/// (Stake Account) Stake Publish Cert
pub const stake_publish = 90

/// (Club Policy) Stake Withdraw
pub const stake_withdraw = 91
