Fabricator(:wordindex) do
  word 											{ Faker::Name.first_name }
  description               { Faker::Movies::StarWars.quote }
end