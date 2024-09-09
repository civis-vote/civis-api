module Types
	module Objects
		module Organisation
			class List < BaseObject
				graphql_name "OrganisationListType"
				field :data,								[Types::Objects::Organisation::Base], nil, null: true
				field :paging,							Types::Objects::Paging,               				nil, null: false
			end
		end
	end
end