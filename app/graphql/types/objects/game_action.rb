module Types
	module Objects
		class GameAction < BaseObject
			field :id,							Int, "ID of the game action", null: false
			field :point_event,			Types::Objects::PointEvent, "Point event stored in the DB for recalculation purposes", null: true
		end
	end
end