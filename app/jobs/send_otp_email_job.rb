class SendOtpEmailJob < ApplicationJob
  queue_as :default

  def perform(otp_request_id)
    otp_request = OtpRequest.find_by(id: otp_request_id)
    return unless otp_request&.created? && otp_request.email?

    UserMailer.send_otp(otp_request.user).deliver_now
  end
end
