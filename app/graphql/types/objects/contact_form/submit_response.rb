module Types
  module Objects
    module ContactForm
      class SubmitResponse < Types::BaseObject
        graphql_name 'ContactFormSubmitResponse'

        field :success, Boolean, null: false
        field :message, String, null: false
      end
    end
  end
end
