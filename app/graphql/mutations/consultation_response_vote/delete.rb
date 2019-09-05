module Mutations
  module ConsultationResponseVote
    class Delete < Mutations::BaseMutation
      type Boolean, null: false

      argument :consultation_response_id, Integer, required: true

      def resolve(consultation_response_id:)
        current_user = context[:current_user]
        vote = current_user.votes.find_by(consultation_response_id: consultation_response_id).destroy
        return true
      end

      def self.authorized?(object, context)
        context[:current_user].present?
      end
    end
  end
end