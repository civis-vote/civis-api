Fabricator(:response_round) do
	consultation_id						{ Consultation.where.not(status: [:rejected, :submitted]).order("RANDOM()").first.id }
end