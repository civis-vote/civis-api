module Types
	module Objects
		module BlogCategory
			class List < BaseObject
				graphql_name "ListBlogCategoryType"
				field :data,								[Types::Objects::BlogCategory::Base], nil, null: true
				field :paging,							Types::Objects::Paging,            nil, null: false
			end
		end
	end
end
