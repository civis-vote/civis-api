module Types
	module Inputs
		module ConsultationResponse
			class Create < Types::BaseInputObject
				graphql_name "ConsultationResponseCreateInput"
				argument :consultation_id,							Int,																										nil,	required: true
				argument :response_text,								String,																									nil,	required: true
				argument :satisfaction_rating,					Types::Enums::ConsultationResponseSatisfactionRatings,	nil,	required: true
				argument :template_id,									Int,																										"ID of the response you are using as a template",	required: true
				argument :visibility,										Types::Enums::ConsultationResponseVisibilities,					nil,	required: true
			end
		end
	end
end