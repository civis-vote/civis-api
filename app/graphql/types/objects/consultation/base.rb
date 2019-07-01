module Types
	module Objects
		module Consultation
			class Base < BaseObject
				graphql_name "BaseConsultationType"
				field :id,													Int, "ID of the consultation", null: false
				field :anonymous_responses,					Types::Connections::ConsultationResponse, nil, null: true
				field :created_at,									Types::Objects::DateTime, nil, null: false
				field :created_by,									Types::Objects::User::Base, nil, null: false
				field :ministry,										Types::Objects::Ministry, nil, null: false
				field :response_count,							Int, nil, null: false
				field :response_deadline, 					Types::Objects::DateTime, "Deadline to submit responses.", null: false
				field :responses,										Types::Connections::ConsultationResponse, nil, null: true
				field :shared_responses,						Types::Connections::ConsultationResponse, nil, null: true
				field :status,											Types::Enums::ConsultationStatuses, nil, null: false
				field :summary,											String, nil, null: true
				field :title,												String, nil, null: false
				field :updated_at,									Types::Objects::DateTime, nil, null: false
				field :url,													String, nil, null: false
			end
		end
	end
end