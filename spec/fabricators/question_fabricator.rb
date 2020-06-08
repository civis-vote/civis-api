Fabricator(:question) do
  consultation_id { Consultation.order("RANDOM()").first }
  question_text { Faker::Movies::StarWars.quote }
  question_type { Question.question_types.to_a.sample.first }
end