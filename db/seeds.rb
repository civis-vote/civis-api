# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'database_cleaner'
require 'faker'

puts "Cleaning the database ...\n"
DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean

puts "---> Importing Ministry Categories"
Rake::Task["import_records_from_array:ministry_categories"].invoke("")
Rake::Task["import_records_from_array:ministry_categories"].reenable

puts "---> Importing Ministries"
Rake::Task["import_records_from_csv:ministries"].invoke("")
Rake::Task["import_records_from_csv:ministries"].reenable

puts "---> Importing Locations"
Rake::Task["import_records_from_csv:locations"].invoke("")
Rake::Task["import_records_from_csv:locations"].reenable

puts "---> Fabricating 50 users"
Fabricate.times(50, :user)

puts "---> Fabricating API Team"
Fabricate(:user, email: "mkv@commuatus.com")

puts "---> Fabricating 10 consultations"
Fabricate.times(10, :consultation)