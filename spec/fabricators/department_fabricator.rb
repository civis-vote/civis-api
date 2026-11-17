Fabricator(:department) do
  name	{ Faker::Movies::StarWars.character }
  level	{ Department.levels.to_a.sample.first }
  is_approved	{ true }
  department_contacts_attributes { [{ contact_type: :primary, name: Faker::Name.name, email: Faker::Internet.email }] }
end
