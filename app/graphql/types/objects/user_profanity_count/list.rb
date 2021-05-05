module Types
	module Objects
		module UserProfanityCount
			class List < BaseObject
				graphql_name "ListUserProfanityCountType"
				field :data,								[Types::Objects::UserProfanityCount::Base], nil, null: true
				# field :paging,							Types::Objects::Paging,            nil, null: false
			end
		end
	end
end