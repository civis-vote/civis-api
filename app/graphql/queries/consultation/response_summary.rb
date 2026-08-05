module Queries
  module Consultation
    class ResponseSummary < Queries::BaseQuery
      description "Aggregated summary of options selected across all responses for a consultation (computed on expiry)"

      argument :id, Int, "ID of the consultation", required: true

      type Types::Objects::ConsultationResponse::Summary, null: true

      def resolve(id:)
        consultation = ::Consultation.find(id)
        consultation.response_summary.presence
      end
    end
  end
end
