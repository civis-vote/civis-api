class VerifyUserEmailJob < ApplicationJob
  queue_as :default

  def perform(user)
    UserMailer.verify_email(user)
  end
end
