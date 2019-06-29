module Types
	module Objects
		module Consultation
			class Base < BaseObject
				field :id,								Int, "ID of the consultation", null: false
				field :ministry,					Types::Objects::Ministry, nil, null: false
				field :response_deadline, Types::Objects::DateTime, "Deadline to submit responses.", null: false
				field :title,							String, nil, null: false
				field :url,								String, nil, null: false
			end
		end
	end
end