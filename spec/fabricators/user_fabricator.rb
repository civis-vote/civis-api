Fabricator(:user) do
	first_name 											{ Faker::Name.first_name }
	last_name 											{ Faker::Name.last_name }
	email 													{ "civis+#{Faker::Name.unique.first_name}@findemail.info" }
	password 												{ Faker::Internet.password(min_length: 8) }
  city_id   											{ Location.cities.order("RANDOM()").first.id }
  notify_for_new_consultation 		{ [true, false].sample }
  role														{ "citizen" }
  phone_number										{ rand(10 ** 10) }
  after_build											{ |user, transients| user.skip_confirmation_notification! }
end