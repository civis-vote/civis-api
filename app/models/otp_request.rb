class OtpRequest < ApplicationRecord
  include Auth::OtpRequest

  after_commit :send_otp_email
  belongs_to :user
  enum :status, { created: 0, verified: 1, resent: 2, time_out: 3, cancelled: 4 }

  def send_otp_email
    SendOtpEmailJob.perform_later(user_id)
  end
end
