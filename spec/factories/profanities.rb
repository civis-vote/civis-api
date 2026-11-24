FactoryBot.define do
  factory :profanity do
    profane_word { "profane#{SecureRandom.hex(4)}" }

    # created_by is required and stamped from Current.user — set one when no admin is signed in.
    before(:create) { Current.user ||= FactoryBot.create(:user, role: :admin) }
  end
end
