module Types
	module Objects
		module GlossaryMapping
			class Base < BaseObject
				graphql_name "GlossaryMappingBase"
				field :id,							Int, "ID of the location", null: false
				field :consultation_id,				String, nil, null: false
				field :glossary_id,				String, nil, null: false
				field :consultation, 				Types::Objects::Consultation::Base, nil, null: false
				field :wordindex,				Types::Objects::Glossary::Base, nil, null: false
			end
		end
	end
end