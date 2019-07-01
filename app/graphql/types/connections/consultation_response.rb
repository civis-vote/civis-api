module Types
	module Connections
		class ConsultationResponse < Types::BaseConnection
			graphql_name "ConsultationResponseConnection"
			edge_type(Types::Edges::ConsultationResponse)
		end
	end
end