module Types
	module Objects
		class PointEvent < BaseObject
			field :id,							Int, "ID of the point event", null: false
			field :points,					Float, "Points the user earrned", null: true
		end
	end
end