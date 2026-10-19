module Queries
  module Consultation
    class Suggestions < Queries::BaseQuery
      description "Get consultation suggestions relevant to the current user"

      argument :consultation_id, Int, required: false, default_value: nil
      argument :limit, Int, required: false, default_value: 3

      type [Types::Objects::Consultation::Base], null: false

      def resolve(consultation_id:, limit:)
        validate_limit!(limit)
        ::ConsultationSuggestionsService.new(user: context[:current_user], consultation_id:).call(limit:)
      end

      def self.authorized?(_object, context)
        context[:current_user].present?
      end

      private

      def validate_limit!(limit)
        return if (1..::ConsultationSuggestionsService::MAX_LIMIT).cover?(limit)

        raise GraphQL::ExecutionError,
              "limit must be between 1 and #{::ConsultationSuggestionsService::MAX_LIMIT}"
      end
    end
  end
end
