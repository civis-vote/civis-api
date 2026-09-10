Fabricator(:department) do
  name { Faker::Company.unique.name }
  level { Department.levels.keys.sample }
  after_build do |department|
    department.department_contacts.build(contact_type: :primary, email: Faker::Internet.email,
                                         name: Faker::Name.name, designation: Faker::Job.title)
  end
end
