module Types
  module Inputs
    module Auth
      class SignUp < Types::BaseInputObject
        description "Attributes for creating a user"

        argument :callback_url, String, nil, required: false
        argument :city_id, Int, nil, required: false
        argument :designation, String, nil, required: false
        argument :email, String, nil, required: true
        argument :first_name, String, nil, required: true
        argument :last_name, String, nil, required: false
        argument :notify_for_new_consultation, Boolean, nil, required: false
        argument :newsletter_subscription, Boolean, nil, required: false
        argument :organization, String, nil, required: false
        argument :password, String, nil, required: true
        argument :phone_number, String, nil, required: false
        argument :referring_consultation_id, Int, nil, required: false
      end
    end
  end
end
