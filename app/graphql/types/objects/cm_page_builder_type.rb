module Types
	module Objects
	  class CmPageBuilderType < BaseObject
		  field :id,                        String, nil, null: false
		  field :components,                [GraphQL::Types::JSON], nil, null: true do
		    argument :max_width, Int, required: false, default_value: nil
		  end
		end
	end
end