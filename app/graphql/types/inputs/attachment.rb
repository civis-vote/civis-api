module Types
	module Inputs
		class Attachment < Types::BaseInputObject
			graphql_name "AttachmentInput"

			description "Attributes needed to attach a fiile"

			argument :filename,		String, nil, required: true
			argument :content,		String, nil, required: true

		end
	end
end