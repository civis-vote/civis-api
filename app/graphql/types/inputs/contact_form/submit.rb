module Types
  module Inputs
    module ContactForm
      class Submit < Types::BaseInputObject
        graphql_name 'ContactFormSubmitInput'

        argument :name, String, nil, required: true
        argument :phone_number, String, nil, required: false
        argument :organisation_name, String, nil, required: false
        argument :message, String, nil, required: true
      end
    end
  end
end
