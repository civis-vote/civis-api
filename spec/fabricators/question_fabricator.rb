Fabricator(:question) do
  response_round_id { ResponseRound.order("RANDOM()").first }
  question_text { Faker::Movies::StarWars.quote }
  question_type { Question.question_types.to_a.sample.first }
end