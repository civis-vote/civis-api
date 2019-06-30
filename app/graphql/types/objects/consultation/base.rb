module Types
	module Objects
		module Consultation
			class Base < BaseObject
				graphql_name "BaseConsultationType"
				field :id,								Int, "ID of the consultation", null: false
				field :created_at,				Types::Objects::DateTime, nil, null: false
				field :updated_at,				Types::Objects::DateTime, nil, null: false
				field :created_by,				Types::Objects::User::Base, nil, null: false
				field :ministry,					Types::Objects::Ministry, nil, null: false
				field :response_deadline, Types::Objects::DateTime, "Deadline to submit responses.", null: false
				field :status,						Types::Enums::ConsultationStatuses, nil, null: false
				field :title,							String, nil, null: false
				field :url,								String, nil, null: false
			end
		end
	end
end