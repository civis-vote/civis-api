module Types
	module Connections
		class Question < Types::BaseConnection
			graphql_name "QuestionConnection"
			edge_type(Types::Edges::Question)
		end
	end
end