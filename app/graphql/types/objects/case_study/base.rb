module Types
	module Objects
		module CaseStudy
			class Base < BaseObject
				graphql_name "CaseStudyBase"
				field :id,									Int, "ID of the location", null: false
				field :created_at,					Types::Objects::DateTime, nil, null: false
				field :created_by,					Types::Objects::User::Base, nil, null: false
				field :ministry_name,				String, nil, null: false
				field :name,								String, nil, null: false
				field :no_of_citizens,			Integer, nil, null: false
				field :url,									String, nil, null: false
			end
		end
	end
end