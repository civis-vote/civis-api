class ApplicationMailer < ActionMailer::Base
  layout "mailer"

  def template_model_base
    @template_model_base ||= {
      project_name: Rails.configuration.x.project_settings.name,
      logo_url: Rails.configuration.x.project_settings.logo_url,
      current_year: Date.today.year.to_s
    }
  end

	@@postmark_key = Rails.application.credentials.dig(:postmark, :api_key)
	@@postmark_client = Postmark::ApiClient.new(@@postmark_key)
	@@from_email = "Civis #{(Rails.env.production? ? '' : "- #{Rails.env.titleize} ")}<support@platform.civis.vote>"
end