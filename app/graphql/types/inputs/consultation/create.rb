module Types
  module Inputs
    module Consultation
      class Create < Types::BaseInputObject
        graphql_name 'ConsultationCreateInput'
        argument :department_id, ID, nil, required: true
        argument :title, String, nil, required: true
        argument :odia_title, String, nil, required: false
        argument :hindi_title, String, nil, required: false
        argument :marathi_title, String, nil, required: false
        argument :url, String, nil, required: true
        argument :response_deadline, Types::Objects::DateTime, nil, required: false
        argument :review_type, Types::Enums::ConsultationReviewType, nil, required: false
        argument :visibility, Types::Enums::ConsultationVisibilityType, nil, required: false
        argument :consultation_feedback_email, String, nil, required: false

        def hindi_title
          object.title_hindi if object.title_hindi.present?
        end

        def odia_title
          object.title_odia if object.title_odia.present?
        end

        def marathi_title
          object.title_marathi if object.title_marathi.present?
        end
      end
    end
  end
end
