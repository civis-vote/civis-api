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
    recent_requests = OtpRequest.where(user_id: user_id).where('created_at >= ?', 30.seconds.ago)
    return if recent_requests.count < 5

    errors.add(:base, "You've reached the resend limit. Please wait 30 seconds before trying again.")
  end

  def deliver_otp
    if delivery_channel == 'phone'
      SendOtpWhatsappJob.perform_later(id)
    else
      send_otp_email
    end
  end

  def send_otp_email
    SendOtpEmailJob.perform_later(user_id)
  end
end
