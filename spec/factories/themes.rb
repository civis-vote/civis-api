FactoryBot.define do
  factory :theme do
    name { "Theme #{SecureRandom.hex(4)}" }
  end
end
