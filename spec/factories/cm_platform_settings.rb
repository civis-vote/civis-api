FactoryBot.define do
  factory :cm_platform_setting do
    name { "Setting #{SecureRandom.hex(6)}" }
    slug { "setting-#{SecureRandom.hex(6)}" }
    description { Faker::Lorem.sentence }
    value { 'test-value' }
  end
end
