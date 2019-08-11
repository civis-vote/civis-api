module Types
	module Objects
		module User
			class Base < BaseObject
				field :id,								Integer, 										nil, null: false
				field :city,							Types::Objects::Location, 	"City where the user is registered from.", null: true
				field :first_name, 				String, 										nil, null: false
				field :profile_picture,		Types::Objects::Attachment, nil, null: false
			end
		end
	end
end