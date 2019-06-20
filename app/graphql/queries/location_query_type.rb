Queries::LocationQueryType = GraphQL::InterfaceType.define do
  name "LocationQuery"

	field :locationList, 							types[Types::Objects::LocationType] do
		is_public true
	  description "Get a list of locations"
	  argument :type,							types.String
	  argument :parent_id,				types.Int
	  resolve ->(_, args, _) {
	  	Location.location_type_filter(args[:type]).parent_filter(args[:parent_id])
	  }
	end  

	field :locationAutocomplete, 							types[Types::Objects::LocationType] do
		is_public true
	  description "Get a list of locations"
	  argument :type,							types.String
	  argument :parent_id,				types.Int
	  argument :q,								types.String
	  resolve ->(_, args, _) {
	  	Location.search(args[:q]).location_type_filter(args[:type]).parent_filter(args[:parent_id]).alphabetical.limit(10)
	  }
	end  
end