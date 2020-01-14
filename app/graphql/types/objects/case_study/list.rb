module Types
	module Objects
		module CaseStudy
			class List < BaseObject
				graphql_name "ListCaseStudyType"
				field :data,								[Types::Objects::CaseStudy::Base], nil, null: true
				field :paging,							Types::Objects::Paging,            nil, null: false
			end
		end
	end
end