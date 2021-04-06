module Types
	module Objects
		module Glossary
			class List < BaseObject
				graphql_name "ListGlossaryType"
				field :data,								[Types::Objects::Glossary::Base], nil, null: true
				field :paging,							Types::Objects::Paging,            nil, null: false
			end
		end
	end
end