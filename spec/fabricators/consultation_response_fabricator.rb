Fabricator(:consultation_response) do
	consultation_id						{ Consultation.where.not(status: [:rejected, :submitted]).order("RANDOM()").first.id }
	user_id										{ User.order("RANDOM()").first.id }
	satisfaction_rating				{ ConsultationResponse.satisfaction_ratings.to_a.sample.first }
	visibility								{ ConsultationResponse.visibilities.to_a.sample.first }
	response_text							{ Faker::Lorem.paragraph(sentence_count: 40, supplemental: true, random_sentences_to_add: 6) }
	response_round_id					{ Consultation.where(consultation_id).response_rounds.last.id }
end