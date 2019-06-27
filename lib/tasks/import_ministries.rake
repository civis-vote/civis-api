require 'csv'
namespace :import_records_from_csv do

	task :ministries => :environment do 
		filepath = Rails.root + "imports/ministries.csv"
		CSV.foreach(filepath, headers: true) do |csv_ministry|
			if csv_ministry['name'].present?
				cover_photo_base_url = 'https://storage.googleapis.com/civis-api-static/ministry-cover-photos/'
				logo_base_url = 'https://storage.googleapis.com/civis-api-static/ministry_logos/'
				ministry = Ministry.new
				ministry.name = csv_ministry['name'].strip
				ministry.level = csv_ministry['level'].strip.downcase
				ministry.poc_email_primary = csv_ministry['poc_primary']
				ministry.poc_email_secondary = csv_ministry['poc_secondary']
				ministry.is_approved = true
				ministry.save!
				puts logo_base_url + csv_ministry['logo'].strip
				logo_image = open(logo_base_url + csv_ministry['logo'].strip)
				ministry.logo.attach(io: logo_image, filename: csv_ministry['logo'].strip)
				puts cover_photo_base_url + csv_ministry['cover_photo'].strip
				cover_photo_image = open(cover_photo_base_url + csv_ministry['cover_photo'].strip)
				ministry.cover_photo.attach(io: cover_photo_image, filename: csv_ministry['cover_photo'].strip)
			end
		end
	end

end