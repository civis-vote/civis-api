RubyLLM.configure do |config|
  config.openai_api_key = Rails.application.credentials.openai[:api_key]
end
