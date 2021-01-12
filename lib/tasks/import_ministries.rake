require "csv"
namespace :import_records_from_csv do

	task :ministries => :environment do 
		filepath = Rails.root + "imports/ministries.csv"
		CSV.foreach(filepath, headers: true) do |csv_ministry|
			ministry = Ministry.find_or_initialize_by(name: csv_ministry["name"])
			if csv_ministry["name"].present?
				cover_photo_base_url = "https://storage.googleapis.com/civis-api-static/ministry-cover-photos/"
				logo_base_url = "https://storage.googleapis.com/civis-api-static/ministry_logos/"
				ministry.name = csv_ministry["name"].strip
				ministry.level = csv_ministry["level"].strip.downcase
				ministry.poc_email_primary = csv_ministry["poc_email_primary"]
				ministry.poc_email_secondary = csv_ministry["poc_email_secondary"]
				ministry.is_approved = true
				ministry.created_by_id = User.admin.first.id
				ministry.save!
				logo_image = open(logo_base_url + csv_ministry["logo"].strip)
				uploader = ImageUploader.new(:store)
        uploaded_file = uploader.upload(logo_image)
        uploaded_file.metadata["filename"] = csv_ministry["logo"].strip
        ministry.update(logo_data: uploaded_file.to_json)
			end
		end
	end

end