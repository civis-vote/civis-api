class InviteExistingUserJob < ApplicationJob
  queue_as :default

  def perform(user, password)
  	client_url = URI::HTTP.build(Rails.application.config.client_url)
    UserMailer.existing_user_email(user, password, client_url).deliver_now
  end
end
