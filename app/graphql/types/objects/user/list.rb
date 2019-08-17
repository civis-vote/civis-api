module Types
	module Objects
		module User
			class List < BaseObject
				graphql_name "ListUserType"
				field :data,								[Types::Objects::User::Base], nil, null: true
				field :paging,							Types::Objects::Paging,       nil, null: false
			end
		end
	end
end