FactoryBot.define do
  factory :showcase_slide do
    title { "Slide #{SecureRandom.hex(6)}" }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    cta_url { Faker::Internet.url }
    cta_label { 'Learn More' }
    status { :published }
    position { rand(1..100) }
    published_at { Time.current }
  end
end
