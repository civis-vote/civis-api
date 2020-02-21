# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require "database_cleaner"
require "faker"

puts "Cleaning the database ...\n"
DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean

puts "---> Importing Ministry Categories"
Rake::Task["import_records_from_array:ministry_categories"].invoke("")
Rake::Task["import_records_from_array:ministry_categories"].reenable

puts "---> Importing Locations"
Rake::Task["import_records_from_csv:locations"].invoke("")
Rake::Task["import_records_from_csv:locations"].reenable

puts "---> Importing Point Scale"
Rake::Task["import_records_from_csv:point_scale"].invoke("")
Rake::Task["import_records_from_csv:point_scale"].reenable

puts "---> Fabricating API Team"
Fabricate(:user, email: "mkv@commutatus.com")
Fabricate(:user, email: "balaji@commutatus.com")

puts "---> Importing Ministries"
Rake::Task["import_records_from_csv:ministries"].invoke("")
Rake::Task["import_records_from_csv:ministries"].reenable



puts "---> Fabricating 50 users"
Fabricate.times(50, :user)


puts "---> Fabricating 10 consultations"
Fabricate.times(50, :consultation)

puts "---> Publish some consultations"
Consultation.where(status: :submitted).order("RANDOM()").limit(30).each do |consultation|
	consultation.publish
end

puts "---> Reject some consultations"
Consultation.where(status: :submitted).order("RANDOM()").limit(10).each do |consultation|
	consultation.reject
end

puts "---> Expire some consultations"
Consultation.where(status: :published).order("RANDOM()").limit(10).each do |consultation|
	consultation.expire
end

puts "---> Responding to some consultations"
Consultation.where(status: [:published, :rejected]).each do |consultation|
	response_count = [0, 1, 2, 3, 4, 5].sample
	Fabricate.times(response_count, :consultation_response, consultation_id: consultation.id)
end

