module Types
  module Inputs
    module Auth
      class ResetPassword < Types::BaseInputObject
        argument :reset_password_token,         String, nil, required: true
        argument :password,                     String, nil, required: true
      end
    end
  end
end 