require "csv"
namespace :import_records_from_csv do

	task :point_scale => :environment do 
		filepath = Rails.root + "imports/point_scale.csv"
		CSV.foreach(filepath, headers: true) do |csv_point_scale_action|
			upper_limit = csv_point_scale_action["upper_limit"]
			PointScale.actions.each do |action_name, value|
				if csv_point_scale_action[action_name].present?
					point_scale = PointScale.new
					point_scale.action = action_name
					point_scale.upper_limit = upper_limit
					point_scale.points = csv_point_scale_action[action_name].to_f
					point_scale.save!
				else
					puts "Action not present - #{action_name}"
				end
			end
		end
	end

end
