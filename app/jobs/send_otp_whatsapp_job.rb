class SendOtpWhatsappJob < ApplicationJob
  queue_as :default

  def perform(otp_request_id)
    otp_request = OtpRequest.find_by(id: otp_request_id)
    return unless otp_request&.created? && otp_request.phone?
    return if otp_request.user&.phone_number.blank?

    GupshupWhatsappDelivery.new.deliver(user: otp_request.user, otp: otp_request.otp, template: :otp)
  end
end
