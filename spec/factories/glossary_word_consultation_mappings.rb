FactoryBot.define do
  factory :glossary_word_consultation_mapping do
    consultation
    glossary { association :wordindex }
  end
end
