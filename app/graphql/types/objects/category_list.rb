module Types
	module Objects
		class CategoryList < BaseObject
			graphql_name "ListCategoryType"
			field :data,								[Types::Objects::Category], 					nil, null: true
			field :paging,							Types::Objects::Paging,               nil, null: false
		end
	end
end