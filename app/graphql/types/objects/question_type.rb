module Types
	 module Objects
 		 class QuestionType < BaseObject
  			graphql_name 'BaseQuestionType'
  			field :id,	Int, 'ID of the question', null: false
  			field :is_optional,	Boolean, nil, null: false
  		  field :question_type, String, nil, null: true
				field :question_text, String, nil, null: true
  		  field :english_question_text, String, nil, null: true
				field :hindi_question_text, String, nil, null: true
				field :odia_question_text, String, nil, null: true
  		  field :parent,	Types::Objects::QuestionType, nil, null: true
  		  field :sub_questions, [Types::Objects::QuestionType], nil, null: true
  		  field :supports_other, Boolean, nil, null: false

				def english_question_text
  						object.question_text if object.question_text.present?
      	end

  			def hindi_question_text
   				 object.question_text_hindi if object.question_text_hindi.present?
   			end

				def odia_question_text
  	 				object.question_text_odia if object.question_text_odia.present?
      	end
  		end
 	end
end
