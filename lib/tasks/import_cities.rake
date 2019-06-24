require 'csv'
namespace :import_records_from_csv do

	task :locations => :environment do 
		filepath = Rails.root + "imports/cities.csv"
		CSV.foreach(filepath, headers: true) do |csv_city|
			if csv_city['City'].present?
				state = Location.states.where(name: csv_city['State']).first_or_create
				city = state.children.cities.where(name: csv_city['City']).first_or_create
				puts "added #{city.name} to #{state.name}"
			end
		end
	end

end
