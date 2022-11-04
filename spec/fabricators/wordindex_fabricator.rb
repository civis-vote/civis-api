Fabricator(:wordindex) do
  word 											{ Faker::Name.first_name }
  description               { Faker::Movies::StarWars.quote }
  created_by_id             { User.admin.first.id }
end