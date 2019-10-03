class ForgotPasswordEmailJob < ApplicationJob
  queue_as :default

  def perform(user, url)
    UserMailer.forgot_password_email(user, url).deliver_now
  end
end
