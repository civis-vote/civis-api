require "csv"
namespace :delete_users_from_staging do
  task :execute => :environment do 
    filepath = Rails.root + "imports/inactive_staging_users.csv"
	CSV.foreach(filepath, headers: true) do |row|
      user = User.find_by(email: row["Email"])
      if user.present?
        user.deactivate
        user.update_column("email", "#{SecureRandom.hex(5)}@deleteduser_staging.com")
      end
    end
  end
end