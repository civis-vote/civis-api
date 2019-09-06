module Types
  class MutationType < Types::BaseObject
    field :auth_change_password,                    resolver: Mutations::Auth::ChangePassword
    field :auth_confirm_email,                      resolver: Mutations::Auth::ConfirmEmail
    field :auth_login,                              resolver: Mutations::Auth::Login
    field :auth_sign_up,                            resolver: Mutations::Auth::SignUp
    field :consultation_create,                     resolver: Mutations::Consultation::Create
    field :consultation_response_create,            resolver: Mutations::ConsultationResponse::Create
    field :current_user_update,                     resolver: Mutations::CurrentUser::Update
    field :game_action_create,                      resolver: Mutations::GameAction::Create
    field :ministry_create,                         resolver: Mutations::Ministry::Create
    field :vote_create,                             resolver: Mutations::ConsultationResponseVote::Create
  end
end