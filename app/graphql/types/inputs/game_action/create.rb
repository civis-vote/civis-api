module Types
	module Inputs
		module GameAction
			class Create < Types::BaseInputObject
				graphql_name "GameActionCreateInput"
				argument :action,	Types::Enums::GameActionTypes,	"Type of action that should be gamified",	required: true
			end
		end
	end
end