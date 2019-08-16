module Types
	module Inputs
		module ConsultationResponseVote
			class Create < Types::BaseInputObject
				graphql_name "VoteCreateInput"
				argument :vote_direction,						Types::Enums::VoteDirections,	"Up/Down vote",	required: true
				argument :consultation_response_id,	Integer, nil, required: true
			end
		end
	end
end