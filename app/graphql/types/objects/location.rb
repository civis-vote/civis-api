module Types
	module Objects
		class Location < BaseObject
			field :id,							Int, "ID of the location", null: false
			field :location_type,		Types::Enums::LocationTypes, nil, null: false
			field :name,						String, nil, null: false
			field :parent,					Types::Objects::Location, "Parent of location", null: true
		end
	end
end