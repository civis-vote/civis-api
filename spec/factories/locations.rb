FactoryBot.define do
  factory :location do
    name { Faker::Address.city }
    location_type { :city }
  end
end
