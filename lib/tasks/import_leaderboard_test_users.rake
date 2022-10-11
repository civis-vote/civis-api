require "csv"
namespace :import_records_from_csv do

	task :leaderboard_test_users => :environment do 
		filepath = Rails.root + "imports/leaderboard_test_users.csv"
		CSV.foreach(filepath, headers: true) do |csv_leaderboard_test_users|
			leaderboard_test_user = 
				User.find_or_initialize_by(email: csv_leaderboard_test_users["email"])
			if csv_leaderboard_test_users["email"].present?
				leaderboard_test_user_email = csv_leaderboard_test_users["email"].strip
				leaderboard_test_user_password = csv_leaderboard_test_users["password"]
				leaderboard_test_user_role = csv_leaderboard_test_users["role"]
				leaderboard_test_user_confirmed_at = csv_leaderboard_test_users["confirmed_at"]
				leaderboard_test_user_city_id = csv_leaderboard_test_users["city_id"]
				leaderboard_test_user_points = csv_leaderboard_test_users["points"]
				puts "Fabricating user " + leaderboard_test_user_email + " start"
				Fabricate(:user, email: leaderboard_test_user_email, password: leaderboard_test_user_password, role: leaderboard_test_user_role, 
				confirmed_at: leaderboard_test_user_confirmed_at, city_id: leaderboard_test_user_city_id, points: leaderboard_test_user_points)
				puts "Fabricating user " + leaderboard_test_user_email + " end"
			end
		end

		CSV.foreach(filepath, headers: true) do |csv_leaderboard_test_users|
			if csv_leaderboard_test_users["email"].present?
				leaderboard_test_user_email = csv_leaderboard_test_users["email"].strip
				puts "Calculating best rank for user " + leaderboard_test_user_email + " start"
				User.find_by(email: leaderboard_test_user_email).check_for_new_best_rank
				puts "Calculating best rank for user " + leaderboard_test_user_email + " end"
			end
		end
	end
end