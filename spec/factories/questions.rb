FactoryBot.define do
  factory :question do
    question_text { "Question #{SecureRandom.hex(6)}" }
    question_type { :checkbox }
    response_round
  end
end
