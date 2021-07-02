module Types
	module Objects
		module GlossaryMapping
			class List < BaseObject
				graphql_name "ListGlossaryMappingType"
				field :data,								[Types::Objects::GlossaryMapping::Base], nil, null: true
				field :paging,							Types::Objects::Paging,            nil, null: false
			end
		end
	end
end