Fabricator(:blog_category) do
  name { "Category #{SecureRandom.hex(6)}" }
  icon_name { 'fas fa-tag' }
  hex_code { Faker::Color.hex_color }
end
