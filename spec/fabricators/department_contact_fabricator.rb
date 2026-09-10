Fabricator(:department_contact) do
  contact_type { :primary }
  email { Faker::Internet.email }
  name { Faker::Name.name }
  designation { Faker::Name.title }
end
