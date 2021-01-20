class VerifyUserEmailAfter8HoursJob < ApplicationJob
  queue_as :default

  def perform(user_id, consultation_id)
    UserMailer.verify_email_after_8_hours(user_id, consultation_id).deliver_now
  end
end
