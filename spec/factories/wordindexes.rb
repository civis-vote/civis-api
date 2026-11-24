FactoryBot.define do
  factory :wordindex do
    word { "Word #{SecureRandom.hex(6)}" }
    description { Faker::Movies::StarWars.quote }

    # created_by is required and stamped from Current.user — set one when no admin is signed in.
    before(:create) { Current.user ||= FactoryBot.create(:user, role: :admin) }
  end
end
