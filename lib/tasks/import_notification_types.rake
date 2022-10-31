require "csv"
namespace :import_records_from_csv do

	task :notification_types => :environment do 
		filepath = Rails.root + "imports/notification_types.csv"
		CSV.foreach(filepath, headers: true) do |csv_notification_types|
			notification_type = 
				NotificationType.find_or_initialize_by(notification_type: csv_notification_types["notification_type"])
			if csv_notification_types["notification_type"].present?
				notification_type.notification_type = csv_notification_types["notification_type"].strip
				notification_type.notification_main_text = csv_notification_types["notification_main_text"]
				notification_type.notification_sub_text = csv_notification_types["notification_sub_text"]
				notification_type.created_at = Date.parse(csv_notification_types["created_at"])
				notification_type.updated_at = Date.parse(csv_notification_types["updated_at"])
				notification_type.save!
			end
		end
	end
end