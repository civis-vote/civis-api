module Types
	module Objects
		class ApiKey < BaseObject
			field :access_token, 	String, nil, null: false
			field :expires_at, Types::Objects::DateTime, nil, null: false
		end
	end
end