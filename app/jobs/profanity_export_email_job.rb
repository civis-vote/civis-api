class ProfanityExportEmailJob < ApplicationJob
  queue_as :default

  def perform(profanities, email)
    UserMailer.profanity_export_email_job(profanities, email).deliver_now
  end
end