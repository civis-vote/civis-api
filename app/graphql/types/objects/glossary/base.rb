module Types
	module Objects
		module Glossary
			class Base < BaseObject
				graphql_name "GlossaryBase"
				field :id,							Int, "ID of the location", null: false
				field :created_at,					Types::Objects::DateTime, nil, null: false
				field :created_by,					Types::Objects::User::Base, nil, null: false
				field :word,						String, nil, null: false
				field :description,					String, nil, null: false
			end
		end
	end
end