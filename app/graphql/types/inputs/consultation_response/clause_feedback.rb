module Types
  module Inputs
    module ConsultationResponse
      class ClauseFeedback < Types::BaseInputObject
        graphql_name "ClauseFeedbackInput"
        description "Clause feedback submitted with a consultation response"

        argument :clause_id,          Int,    "ID of the clause being feedbacked", required: true
        argument :feedback_comment,   String, "Feedback comment", required: false
        argument :feedback_reason,    String, "Reason for the feedback", required: false
      end
    end
  end
end
