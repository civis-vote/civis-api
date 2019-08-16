class GameAction < ApplicationRecord

	include Scorable::GameAction

  belongs_to :user
  belongs_to :point_event, optional: true

  enum action: { consultation_shared: 0, commented: 1, commented_on_thread: 2 }

end