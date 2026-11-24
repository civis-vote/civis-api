FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    email      { "civis+#{SecureRandom.hex(8)}@findemail.info" }
    password   { 'Federation@123' }
    role       { 'citizen' }
    phone_number { "+9198#{Array.new(8) { rand(10) }.join}" }

    city { association :location, location_type: :city }
    cm_role
  end
end
