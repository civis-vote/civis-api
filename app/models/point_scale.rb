class PointScale < ApplicationRecord

	# enums
	enum :action, { user_created: 0, response_submitted: 1, public_response_submitted: 2, consultation_shared: 3, response_used: 4, consultation_created: 5, ministry_created: 6, commented: 7, commented_on_thread: 8 }

end