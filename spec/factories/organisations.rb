FactoryBot.define do
  factory :organisation do
    name { "Organisation #{SecureRandom.hex(6)}" }

    # created_by is required and stamped from Current.user — set one when no admin is signed in.
    before(:create) { Current.user ||= FactoryBot.create(:user, role: :admin) }
  end
end
