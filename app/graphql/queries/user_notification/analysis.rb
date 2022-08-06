module Queries
	module UserNotification
		class Analysis < Queries::BaseQuery
	    description "User Notifications as a JSON for a given user id"
	    argument :user_id,		Int,		required: true
	    
	    type GraphQL::Types::JSON, null: true

			def resolve(user_id:)
				# Call the notification approaching deadline from the user model
				user = ::User.find(user_id)
				user.notification_approaching_deadline
				
				user_notification = ::UserNotification.new
				
				up_vote_json_string = user_notification.check_notification(user_id, 'RESPONSE_UPVOTE')
				response_used_json_string = user_notification.check_notification(user_id, 'RESPONSE_USED')
				
				rank_json_string = user_notification.check_rank_notification(user_id)
				
				consultation_approaching_deadline_json_string = user_notification.check_notification(user_id, 'CONSULTATIONS_NEARING_DEADLINE')
				
				user_notification.create_newly_created_consultation_notification(user_id, 'NEWLY_PUBLISHED_CONSULTATIONS')
				
				new_consultation_json_string = user_notification.check_notification(user_id, 'NEWLY_PUBLISHED_CONSULTATIONS')
				consultation_status_json_string = user_notification.check_notification(user_id,'CITIZEN_SUBMITTED_CONSULTATION_STATUS')

				return {
					all: [up_vote_json_string,
					response_used_json_string,
					rank_json_string,
					consultation_approaching_deadline_json_string,
					new_consultation_json_string,
					consultation_status_json_string]
				}

			end
		end
	end
end
