Queries::ConstantQueryType = GraphQL::InterfaceType.define do
  name "ConstantQuery"

	field :constantByType, 							types[Types::Objects::ConstantType] do
		is_public true
	  description "Search for constants by supplying a type"
	  argument :type,							!types.String
	  resolve ->(_, args, _) {
	  	Constant.where(type_id: args[:type])
	  }
	end

	field :constantHashMap,							Types::Objects::JsonType do 
		is_public true
		description "Returns a hash map for all constants on the system"
		resolve -> (_, _, _){
			Constant.hash_map
		}
	end

	field :constantVersion,								types.Int do 
		is_public true
		description "Returns a hardcoded version number for constants on the system"
		# TODO - find a better way to do this
		resolve -> (_, _, _){
			return 1
		}
	end

  
end