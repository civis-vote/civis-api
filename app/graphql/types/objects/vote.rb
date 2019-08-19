module Types
	module Objects
		class Vote < BaseObject
			field :id,							Integer, "ID of the vote", null: false
			field :vote_direction,	Types::Enums::VoteDirections, nil, null: true
		end
	end
end