module Types
	 module Inputs
 		 module Consultation
  			 class Create < Types::BaseInputObject
   				 graphql_name 'ConsultationCreateInput'
   				 argument :ministry_id,	Int,	nil,	required: true
   				 argument :title,	String,	nil,	required: true
				 argument :english_title,	String,	nil,	required: false
				 argument :odia_title,	String,	nil,	required: false
				 argument :hindi_title,	String,	nil,	required: false
   				 argument :url,	String,	nil,	required: true
   				 argument :response_deadline,	Types::Objects::DateTime,	nil,	required: false
   				 argument :review_type,						Types::Enums::ConsultationReviewType,	nil,	required: false
   				 argument :visibility,							Types::Enums::ConsultationVisibilityType,	nil,	required: false
        argument :consultation_feedback_email, String, nil, required: false

				def english_title
   					object.title if object.title.present?
        		end

   				def hindi_title
    				object.title_hindi if object.title_hindi.present?
    			end

   				def odia_title
    				object.title_odia if object.title_odia.present?
        		end
   			end
  		end
 	end
end
