RubyLLM.configure do |config|
  config.openrouter_api_key = Rails.application.credentials.dig(:openrouter, :api_key)
end
