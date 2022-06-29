module Queries
	module UserNotification
		class Analysis < Queries::BaseQuery
	    description "User Notifications as a JSON for a given user id"
	    argument :user_id,		Int,		required: true
	    
	    type GraphQL::Types::JSON, null: true

			def resolve(user_id:)
				up_vote_main_text =  ::NotificationType.get_main_text('RESPONSE_UPVOTE')
				up_vote_sub_text =  ::NotificationType.get_sub_text('RESPONSE_UPVOTE')
				up_vote_consultation_list = ::UserNotification.up_vote_filter(user_id, 'RESPONSE_UPVOTE')

				response_used_main_text =  ::NotificationType.get_main_text('RESPONSE_USED')
				response_used_sub_text =  ::NotificationType.get_sub_text('RESPONSE_USED')
				response_used_consultation_list = ::UserNotification.response_used_filter(user_id, 'RESPONSE_USED')

				return {
					up_vote: {
					up_vote_main_text: up_vote_main_text,
					up_vote_sub_text: up_vote_sub_text,
					up_vote_array: up_vote_consultation_list
					},
					response_used: {
					response_used_main_text: response_used_main_text,
					response_used_sub_text: response_used_sub_text,
					response_used_array: response_used_consultation_list
					}			
				}
			end
		end
	end
end
