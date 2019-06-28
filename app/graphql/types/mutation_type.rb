module Types
  class MutationType < Types::BaseObject
    field :auth_sign_up,				resolver: Mutations::Auth::SignUp
    field :auth_login,					resolver: Mutations::Auth::Login
    field :auth_confirm_email, 	resolver: Mutations::Auth::ConfirmEmail
    field :ministry_create,			resolver: Mutations::Ministry::Create
  end
end