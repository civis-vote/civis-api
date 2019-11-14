Fabricator(:case_study) do
  name           { Faker::Movies::StarWars.quote }
  ministry_name  { Ministry.order('RANDOM()').first.name }
  no_of_citizens { rand(1..100) }
  url            { Faker::Internet.url }
  created_by_id  { User.admin.first.id }
end