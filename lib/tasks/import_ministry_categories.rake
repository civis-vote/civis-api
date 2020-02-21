require "csv"
namespace :import_records_from_array do

	task :ministry_categories => :environment do 
		[
			"Education", 
			"Environment & Waste Management", 
			"Healthcare, Women and Child & Sanitation, Accessibility", 
			"Agriculture, Rural Development", 
			"Telecom / Internet / Media",
			"Finance, Energy, Industry",
			"Urban Settlements",
			"Miscellaneous",
		].each do |category_name|
			Constant.create(constant_type: :ministry_category, name: category_name)
		end
	end

end
