FactoryBot.define do
  factory :blog_post do
    title { "Blog Post #{SecureRandom.hex(6)}" }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    content { Faker::Lorem.paragraphs(number: 3).join("\n\n") }
    status { :published }
    published_at { Time.current }
    blog_category
  end
end
