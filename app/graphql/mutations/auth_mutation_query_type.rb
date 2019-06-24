Mutations::AuthMutationQueryType = GraphQL::InterfaceType.define do
  name "AuthMutationQuery"

  field :signUp,                          Types::Objects::ApiKeyType do
    is_public true
    description "Sign up a new user"
    argument :auth,                       Types::Inputs::Auth::CreateUserInput
    resolve ->(_, args, _) {
      user = User.new args[:auth].to_h
      user.save!
      return user.live_api_key
    }
  end


  # field :login,                           Types::Objects::ApiKeyType do
  #   is_public true
  #   description "Existing user signs in with email"
  #   argument :auth,                       Types::Inputs::AuthInput
  # resolve ->(_, argsc, _){
  #     user = User.find_by(email: args[:auth][:email])
  #     if user
  #       if user.valid_password?(args[:auth][:password])
  #         user.find_or_generate_api_key
  #         user.live_api_key
  #       else
  #         return GraphQL::ExecutionError.new("incorrect password") 
  #       end
  #     else
  #       return GraphQL::ExecutionError.new("incorrect email") 
  #     end
  #   } 
  # end

  # field :generateResetPasswordToken,      types.String do 
  #   is_public true
  #   description "An existing user requests a password change"
  #   argument :email,                      types.String
  #   resolve ->(_, args, _){
  #     user = User.find_by(email: args[:email])
  #     if user 
  #       user.generate_reset_password_token
  #       # TODO send verification email
  #       return user.email
  #     end
  #   }
  # end

  # field :resetPassword,                   Types::Objects::ApiKeyType do 
  #   is_public true
  #   description "An existing user can reset their password with the correct token"
  #   argument :reset_password_token,       types.String
  #   argument :password,                   types.String
  #   resolve ->(_, args, _){
  #     user = User.find_by(reset_password_token: args[:reset_password_token])
  #     if user
  #       # Mechanism to expire reset password token in 1 day
  #       if (Time.now - user.reset_password_sent_at) <= 86400
  #         user.reset_password(args[:password], args[:password])
  #         return user.find_or_generate_api_key
  #       else
  #         return GraphQL::ExecutionError.new("password reset token is expired. regenerate a token") 
  #       end
  #     else
  #       return GraphQL::ExecutionError.new("invalid password reset token") 
  #     end
  #   }
  # end                 

end
