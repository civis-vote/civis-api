FactoryBot.define do
  factory :case_study do
    name { "Case Study #{SecureRandom.hex(6)}" }
    ministry_name { 'Ministry of Testing' }
    no_of_citizens { rand(1..100) }
    url { Faker::Internet.url }
    case_study_type { :government }

    # created_by is required and stamped from Current.user — set one when no admin is signed in.
    before(:create) { Current.user ||= FactoryBot.create(:user, role: :admin) }
  end
end
