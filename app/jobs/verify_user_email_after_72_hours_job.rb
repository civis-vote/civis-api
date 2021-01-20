class VerifyUserEmailAfter72HoursJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    UserMailer.verify_email_after_72_hours(user_id).deliver_now
  end
end