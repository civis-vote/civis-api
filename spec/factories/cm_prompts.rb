FactoryBot.define do
  factory :cm_prompt do
    name { "Prompt #{SecureRandom.hex(6)}" }
    slug { "prompt-#{SecureRandom.hex(6)}" }
  end
end
