module Types
	module Objects
		class Constant < BaseObject
			field :id,							Int, "ID of the location", null: false
			field :constant_type,		Types::Enums::ConstantTypes, nil, null: false
			field :name,						String, nil, null: false
		end
	end
end