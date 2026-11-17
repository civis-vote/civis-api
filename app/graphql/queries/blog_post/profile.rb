module Queries
	module BlogPost
		class Profile < Queries::BaseQuery
	    description "Get a single published blog post by slug"
	    argument :slug,		String,		required: true

	    type Types::Objects::BlogPost::Base, null: true

	    def resolve(slug:)
	    	::BlogPost.published.find_by(slug: slug)
	    end
		end
	end
end
