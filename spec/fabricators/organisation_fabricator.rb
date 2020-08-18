Fabricator(:organisation) do
  name { Faker::Movies::StarWars.quote }
  created_by_id { User.order("RANDOM()").first.id }
end