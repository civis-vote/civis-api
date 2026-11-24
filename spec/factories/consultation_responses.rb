FactoryBot.define do
  factory :consultation_response do
    consultation
    # Consultation#create already makes its first response round; reuse it so the
    # response belongs to the consultation it is filed against.
    response_round { ResponseRound.where(consultation_id: consultation.id).last || FactoryBot.create(:response_round, consultation:) }
    user
    response_text { Faker::Lorem.paragraph(sentence_count: 5) }
    visibility { :shared }
    satisfaction_rating { :satisfied }
  end
end
