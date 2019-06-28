class ApplicationMailer < ActionMailer::Base
  default from: 'support@civis.vote'
  layout 'mailer'

	@@postmark_key = Rails.application.credentials.postmark[:api_key]
	@@postmark_client = Postmark::ApiClient.new(@@postmark_key)

	def postmark_client

	end

end