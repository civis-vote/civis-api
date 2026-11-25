class OtpRequest < ApplicationRecord
  include Auth::OtpRequest

  after_commit :deliver_otp, on: :create
  belongs_to :user
  enum :status, { created: 0, verified: 1, resent: 2, time_out: 3, cancelled: 4 }
  enum :delivery_channel, { email: 0, phone: 1 }

  validate :validate_resend_limit, on: :create

  def self.delivery_channel_for(identifier)
    identifier.to_s.include?('@') ? :email : :phone
  end

  private

  def validate_resend_limit
    return if OtpRequest.where(user_id:, created_at: 30.seconds.ago..).count < 5

    errors.add(:base, "You've reached the resend limit. Please wait 30 seconds before trying again.")
  end

  def deliver_otp
    phone? ? SendOtpWhatsappJob.perform_later(id) : send_otp_email
  end

  def send_otp_email
    SendOtpEmailJob.perform_later(id)
  end
end
