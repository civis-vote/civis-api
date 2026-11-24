FactoryBot.define do
  factory :cm_role do
    name { "Role #{SecureRandom.hex(4)}" }
  end
end
