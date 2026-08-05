RubyLLM.configure do |config|
  config.openrouter_api_key = Rails.application.credentials.dig(:openrouter, :api_key) || ENV.fetch('OPENROUTER_API_KEY', nil)
  config.default_model = 'google/gemini-3.5-flash'
end
