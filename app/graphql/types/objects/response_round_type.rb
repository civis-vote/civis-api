module Types
	module Objects
		class ResponseRoundType < BaseObject
		  graphql_name "BaseResponseRoundType"
		  field :id, 						Int, "ID of the response round", null: false
		  field :round_number,	Int, nil, null: false
		  field :active,				Boolean, nil, null: false
		  field :questions, [Types::Objects::QuestionType], nil, null: true

		  def active
		  	object.consultation.response_rounds.order(:created_at).last.id == object.id ? true : false
		  end
		end
	end
end