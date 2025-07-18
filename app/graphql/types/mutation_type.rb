module Types
  class MutationType < Types::BaseObject
    field :auth_accept_invite,                      resolver: Mutations::Auth::AcceptInvite
    field :auth_confirm_email,                      resolver: Mutations::Auth::ConfirmEmail
    field :auth_resend_verification_email,          resolver: Mutations::Auth::ResendVerificationEmail
    field :auth_login,                              resolver: Mutations::Auth::Login
    field :verify_otp,                              resolver: Mutations::Auth::VerifyOtp
    field :auth_sign_up,                            resolver: Mutations::Auth::SignUp
    field :consultation_create,                     resolver: Mutations::Consultation::Create
    field :consultation_response_create,            resolver: Mutations::ConsultationResponse::Create
    field :current_user_update,                     resolver: Mutations::CurrentUser::Update
    field :unsubscribe_consultation,                resolver: Mutations::User::UnsubscribeConsultation
    field :game_action_create,                      resolver: Mutations::GameAction::Create
    field :ministry_create,                         resolver: Mutations::Ministry::Create
    field :vote_create,                             resolver: Mutations::ConsultationResponseVote::Create
    field :vote_delete,                             resolver: Mutations::ConsultationResponseVote::Delete
    field :user_count_create,                       resolver: Mutations::UserCount::Create
    field :user_count_update,                       resolver: Mutations::UserCount::Update
  end
end