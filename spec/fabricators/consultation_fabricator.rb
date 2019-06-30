Fabricator(:consultation) do
	title											{Faker::Movies::StarWars.quote}
	summary										{Faker::Lorem.paragraph(50, true, 8)}
	url												{Faker::Internet.url}
	ministry_id								{Ministry.order('RANDOM()').first.id}
	response_deadline					{Date.today + rand(1..50).days}
	created_by_id							{User.order('RANDOM()').first.id}
end