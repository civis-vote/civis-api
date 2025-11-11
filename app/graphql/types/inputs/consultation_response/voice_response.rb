module Types
  module Inputs
    module ConsultationResponse
      class VoiceResponse < Types::BaseInputObject
        graphql_name "ConsultationResponseVoiceResponseInput"
        argument :question_id, ID, nil, required: true
        argument :file, ApolloUploadServer::Upload, nil, required: true
      end
    end
  end
end
