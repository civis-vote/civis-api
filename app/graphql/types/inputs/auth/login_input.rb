Types::Inputs::Auth::LoginInput = GraphQL::InputObjectType.define do
  name 'AuthLoginInput'

  argument :email,                    !types.String
  argument :password,                 !types.String

end