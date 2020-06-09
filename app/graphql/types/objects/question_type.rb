module Types
	module Objects
		class QuestionType < BaseObject
			graphql_name "BaseQuestionType"
			field :id, 						Int, "ID of the question", null: false
		  field :question_type, String, nil, null: true
		  field :question_text, String, nil, null: true
		  field :parent, 				Types::Objects::QuestionType, nil, null: true
		  field :sub_questions, [Types::Objects::QuestionType], nil, null: true
		end
	end
end