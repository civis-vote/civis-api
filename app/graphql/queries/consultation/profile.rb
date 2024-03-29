module Queries
  module Consultation
    class Profile < Queries::BaseQuery
      description "Get a single consultation"
      argument :id, Int, required: true
      argument :response_token, String, required: false, default_value: nil

      type Types::Objects::Consultation::Base, null: true

      def resolve(id:, response_token:)
        consultation = ::Consultation.find(id)

        return consultation
      end
    end
  end
end