FactoryBot.define do
  factory :department do
    name { Faker::Movies::StarWars.character }
    level { Department.levels.keys.sample }
    is_approved { true }

    department_contacts_attributes { [{ contact_type: :primary, name: Faker::Name.name, email: Faker::Internet.email }] }

    # Scorable::Ministry awards points to created_by when a department is approved, and
    # created_by is stamped from Current.user — set one when no admin is signed in.
    before(:create) { Current.user ||= FactoryBot.create(:user, role: :admin) }
  end
end
