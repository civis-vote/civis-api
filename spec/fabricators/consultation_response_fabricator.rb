Fabricator(:consultation_response) do
	consultation_id						{ Consultation.where.not(status: [:rejected, :submitted]).order("RANDOM()").first.id }
	user_id										{ User.order("RANDOM()").first.id }
	satisfaction_rating				{ ConsultationResponse.satisfaction_ratings.to_a.sample.first }
	visibility								{ ConsultationResponse.visibilities.to_a.sample.first }
	response_text							{ Faker::Lorem.paragraph(40, true, 6) }
end