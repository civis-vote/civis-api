Fabricator(:ministry) do
	name											{ Faker::Movies::StarWars.character }
	category_id								{ Category.order("RANDOM()").first.id }
	level											{ Ministry.levels.to_a.sample.first }
	is_approved								{ true }
	poc_email_primary					{ Faker::Internet.email }
	poc_email_secondary				{ Faker::Internet.email }
	created_by_id							{ User.admin.first.id }

	after_save do |ministry|
		require 'open-uri'
		url = URI.parse(Faker::Company.logo)
		logo_image = open(url)
		uploader = ImageUploader.new(:store) 
		uploaded_file = uploader.upload(logo_image)
		uploaded_file.metadata["filename"] = File.basename(url.path)
    ministry.update(logo_data: uploaded_file.to_json)
	end
end