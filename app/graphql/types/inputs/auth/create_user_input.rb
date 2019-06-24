Types::Inputs::Auth::CreateUserInput = GraphQL::InputObjectType.define do
  name 'AuthCreateUserInput'

  argument :first_name,               !types.String
  argument :last_name,                !types.String
  argument :email,                    !types.String
  argument :password,                 !types.String
  argument :city_id,									!types.Int

end
