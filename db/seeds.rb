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

puts "---> Converting Page components to action text"
Rake::Task["consultation:convert_page_to_action_text"].invoke
Rake::Task["consultation:convert_page_to_action_text"].reenable

puts "---> Fabricating API Team"
Fabricate(:user, email: "mkv@commutatus.com", role: "admin")
Fabricate(:user, email: "balaji@commutatus.com", role: "admin")

puts "---> Fabricating 50 categories"
progressbar = ProgressBar.create
50.times { Fabricate(:category); progressbar.increment}

puts "---> Fabricating 50 ministries"
progressbar = ProgressBar.create
50.times { Fabricate(:ministry); progressbar.increment}


puts "---> Fabricating 50 users"
progressbar = ProgressBar.create
50.times { Fabricate(:user); progressbar.increment}


puts "---> Fabricating 10 consultations"
progressbar = ProgressBar.create
50.times { Fabricate(:consultation); progressbar.increment}

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
	Fabricate.times(response_count, :response_round, consultation_id: consultation.id)
	begin
		puts "---> Creating Response Round for consultations"
		Fabricate.times(response_count, :consultation_response, consultation_id: consultation.id, response_round_id: consultation.response_rounds.last.id)
	rescue ActiveRecord::RecordInvalid => exception
		puts "---> #{exception.record.errors.full_messages.join('\n')}"
	end
end

puts "---> Creating Question to consultation"
Fabricate.times(10, :question)
Question.all.each do |question|
	puts "---> Creating sub questions"
	Fabricate.times(4, :question, parent_id: question.id)
end

puts "---> Creating Organisation and employees"
Fabricate.times(5, :organisation)
Organisation.all.each do |organisation|
	puts "---> Creating Employees"
	Fabricate.times(3, :user, role: :organisation_employee, organisation_id: organisation.id)
end

puts "---> Creating Glossary Word"
Fabricate.times(10, :wordindex)