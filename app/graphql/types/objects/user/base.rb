module Types
	module Objects
		module User
			class Base < BaseObject
				field :id,		Int, 		nil, null: false
				field :first_name, 	String, 	nil, 	null: false
				field :last_name, 	String, 	nil, 	null: false
				field :city,	Types::Objects::Location, "City where the user is registered from.", null: true
			end
		end
	end
end