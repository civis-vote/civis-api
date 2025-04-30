class SendOtpEmailJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    UserMailer.send_otp(user).deliver_now
  end
end
