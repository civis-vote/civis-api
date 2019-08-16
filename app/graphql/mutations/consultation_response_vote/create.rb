module Mutations
  module ConsultationResponseVote
    class Create < Mutations::BaseMutation
      type Types::Objects::Vote, null: false

      argument :consultation_response_vote, Types::Inputs::ConsultationResponseVote::Create, required: true

      def resolve(consultation_response_vote:)
        current_user = context[:current_user]
        vote = current_user.votes.create! consultation_response_vote.to_h
        return vote
      end

      def self.authorized?(object, context)
        context[:current_user].present?
      end
    end
  end
end