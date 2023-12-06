use aiken/transaction/value.{PolicyId}

pub type GeneralStateDatum {
  // dùng để giới hạn theo các thao tác spending theo club
  club_policy_id: PolicyId,
  // name của club
  name: ByteArray,
  // tham chiếu kỳ để xác định có phạt rút trước hạn hay ko?
  lockup_period: Int,
  // % phí phạt rút tiền trước hạn
  early_withdrawal_penalty: Int,
  // % phí quản lý club cho ví nắm giữ OP_NFT vận hành club
  management_fee: Int,
  // % lợi suất tối thiểu mà club đảm bảo
  hurdle_rate: Int,
  // % thưởng hiệu suất đầu tư mà ví nắm giữ OP_NFT vận hành club sẽ nhận được
  performance_bonus: Int,
  // tỉ lệ % vốn góp tối thiểu của OP trên tổng vốn hiện hữu của club. noted: OP_Token/(OP_Token + Members_Token)
  min_capital_contribution: Int,
  // thời gian thực hiện giao dịch tạo club
  inception_date: Int,
  // default: 1_000_000 (lovelace)
  share_token_price_init: Int,
}

// gives base object, used for testing
pub fn base_general_state_datum() -> GeneralStateDatum {
  GeneralStateDatum {
    club_policy_id: "",
    name: "",
    lockup_period: 0,
    early_withdrawal_penalty: 0,
    management_fee: 0,
    hurdle_rate: 0,
    performance_bonus: 0,
    min_capital_contribution: 0,
    inception_date: 0,
    share_token_price_init: 1_000_000,
  }
}
