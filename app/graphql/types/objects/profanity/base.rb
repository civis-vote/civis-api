module Types
	module Objects
		module Profanity
			class Base < BaseObject
				graphql_name "ProfanityBase"
				field :id,							Int, "ID of the profane word", null: false
				field :profane_word,				String, nil, null: false
				field :created_by,					Types::Objects::User::Base, nil, null: false
				field :created_at,					Types::Objects::DateTime, nil, null: false
			end
		end
	end
end