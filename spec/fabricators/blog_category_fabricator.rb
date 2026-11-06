Fabricator(:blog_category) do
  name { "Category #{SecureRandom.hex(6)}" }
  hex_code { Faker::Color.hex_color }
end
