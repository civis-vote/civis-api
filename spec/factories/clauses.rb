FactoryBot.define do
  factory :clause do
    clause_id { SecureRandom.hex(4) }
    clause_title { "Clause #{SecureRandom.hex(4)}" }
    what_is_being_proposed { Faker::Lorem.sentence }
    consultation
  end
end
