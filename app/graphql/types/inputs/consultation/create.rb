module Types
	module Inputs
		module Consultation
			class Create < Types::BaseInputObject
				graphql_name "ConsultationCreateInput"
				argument :ministry_id,									Int,																nil,	required: true
				argument :title,												String,															nil,	required: true
				argument :url,													String,															nil,	required: true
				argument :response_deadline,						Types::Objects::DateTime,						nil,	required: false
			end
		end
	end
end