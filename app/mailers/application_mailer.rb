class ApplicationMailer < ActionMailer::Base
  default from: "support@civis.vote"
  layout "mailer"
  class << self; attr_accessor :postmark_key, :postmark_client end

	@postmark_key = Rails.application.credentials.postmark[:api_key]
	@postmark_client = Postmark::ApiClient.new(@postmark_key)

	def postmark_client

	end

end