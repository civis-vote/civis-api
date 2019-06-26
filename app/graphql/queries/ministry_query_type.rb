Queries::MinistryQueryType = GraphQL::InterfaceType.define do
	name "MinistryQuery"

	field :ministryAutocomplete, 							types[Types::Objects::MinistryType] do
	  description "Get a list of ministries"
	  argument :q,								types.String
	  resolve ->(_, args, _) {
	  	Ministry.search(args[:q]).approved.alphabetical
	  }
	end
end