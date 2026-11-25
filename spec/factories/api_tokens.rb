FactoryBot.define do
  factory :api_token do
    user
    name { "Token #{SecureRandom.hex(6)}" }
    token { SecureRandom.hex(16) }
    token_type { :pat }
  end
end
