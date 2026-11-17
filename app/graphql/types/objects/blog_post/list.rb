module Types
	module Objects
		module BlogPost
			class List < BaseObject
				graphql_name "ListBlogPostType"
				field :data, [Types::Objects::BlogPost::Base], nil, null: true
				field :paging, Types::Objects::Paging, nil, null: false
				field :years, [Int], "Years that have published posts, for the year filter", null: true

				def years
					::BlogPost.published_years
				end
			end
		end
	end
end
