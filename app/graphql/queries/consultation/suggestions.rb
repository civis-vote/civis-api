module Queries
  module Consultation
    class Suggestions < Queries::BaseQuery
      description "Get consultation suggestions relevant to the current user"

      argument :consultation_id, Int, required: false, default_value: nil
      argument :limit, Int, required: false, default_value: 3,
                            validates: { numericality: { within: 1..::ConsultationSuggestionsService::MAX_LIMIT } }

      type [Types::Objects::Consultation::Base], null: false

      def resolve(consultation_id:, limit:)
        ::ConsultationSuggestionsService.new(user: context[:current_user], consultation_id:).call(limit:)
      end

      def self.authorized?(_object, context)
        context[:current_user].present?
      end
    end
  end
end
