require 'csv'
namespace :import_records_from_csv do

	task :consultations => :environment do 
		filepath = Rails.root + "imports/consultations.csv"
		CSV.foreach(filepath, headers: true) do |csv_consultations|
			ministry = Ministry.find_by(name: csv_consultations['ministry'])
			consultation = Consultation.find_or_initialize_by(title: csv_consultations['title'])
			if csv_consultations['title'].present?
				consultation.title = csv_consultations['title'].strip
				consultation.url = csv_consultations['url']
				consultation.ministry_id = ministry.id
				consultation.summary = csv_consultations['summary']
				consultation.created_at = Date.parse(csv_consultations['created_at'])
				consultation.response_deadline = Date.parse(csv_consultations['response_deadline'])
				consultation.published_at = Date.parse(csv_consultations['published_at'])
				consultation.status = "published"
				consultation.created_by_id = User.admin.first.id
				consultation.save!
			end
		end
	end
end