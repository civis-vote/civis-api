module Types
	module Objects
		module Profanity
			class List < BaseObject
				graphql_name "ListProfanityType"
				field :data,							[Types::Objects::Profanity::Base], nil, null: true
				field :paging,							Types::Objects::Paging,            nil, null: false
			end
		end
	end
end