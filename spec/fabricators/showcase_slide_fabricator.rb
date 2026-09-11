Fabricator(:showcase_slide) do
  title { Faker::Movies::StarWars.quote }
  description { Faker::Lorem.paragraph(sentence_count: 10) }
  cta_url { Faker::Internet.url }
  video_url { nil }
  cta_label { 'Learn More' }
  banner_type { 'image' }
  status { :published }
  position { rand(1..100) }
  published_at { Time.now }
end
