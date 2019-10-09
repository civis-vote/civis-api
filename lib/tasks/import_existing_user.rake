require 'roo'
require 'securerandom'
namespace :import_records_from_excel do

	task :user => :environment do
		filepath = File.join(Rails.root, '/imports/existing_user.xlsx')
		spreadsheet = Roo::Spreadsheet.open(filepath)
		(2..spreadsheet.last_row).each do |i|
			user = User.find_by(email: spreadsheet.row(i)[9])
			unless user
				password = SecureRandom.hex(3)
				user = User.create(first_name: spreadsheet.row(i)[3], last_name: spreadsheet.row(i)[5], email: spreadsheet.row(i)[9], password: password, points: spreadsheet.row(i)[10], confirmed_at: DateTime.now, notify_for_new_consultation: true)
				InviteExistingUserJob.perform_later(user, password)
			end
		end
	end

end