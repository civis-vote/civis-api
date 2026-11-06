Fabricator(:blog_category) do
  name { "Category #{SecureRandom.hex(6)}" }
end
