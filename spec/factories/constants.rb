FactoryBot.define do
  factory :constant do
    name { "Constant #{SecureRandom.hex(6)}" }
    constant_type { :segment }
  end
end
