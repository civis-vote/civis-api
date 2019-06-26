Types::Inputs::Auth::CreateUserInput = GraphQL::InputObjectType.define do
  name 'AuthCreateUserInput'

  argument :city_id,										!types.Int
  argument :email,                    	!types.String
  argument :first_name,               	!types.String
  argument :last_name,                	!types.String
  argument :notify_for_new_consultation, types.Boolean
  argument :password,                 	!types.String

end