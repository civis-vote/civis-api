Fabricator(:consultation) do
  title { Faker::Movies::StarWars.quote }
  summary { Faker::Lorem.paragraph(sentence_count: 50, supplemental: true, random_sentences_to_add: 8) }
  url { Faker::Internet.url }
  department { Fabricate(:department) }
  response_deadline { Date.today + rand(1..50).days }
  question_flow { :question_list }
  status { :submitted }
  visibility { :public_consultation }
  review_type { :consultation }
end
