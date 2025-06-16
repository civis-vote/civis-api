class ApplicationMailer < ActionMailer::Base
  layout "mailer"

	@@postmark_key = Rails.application.credentials.dig(:postmark, :api_key)
	@@postmark_client = Postmark::ApiClient.new(@@postmark_key)
	@@from_email = "Civis #{(Rails.env.production? ? '' : "- #{Rails.env.titleize} ")}<support@platform.civis.vote>"
end