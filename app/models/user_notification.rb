class UserNotification < ApplicationRecord
    include SpotlightSearch
    include Paginator

    scope :user_id_filter, lambda { |user_id|
        return all unless user_id.present?
        where(user_id: user_id, notification_status: 0)
    }

    scope :notification_filter, lambda { |user_id, notification_type|
        return all unless user_id.present?
        where(user_id: user_id, notification_type: notification_type).select(:id, :consultation_id)
    }

    scope :consultation_id_filter, lambda { |consultation_id, user_id|
        return all unless user_id.present?
        where(oldrank: consultation_id, user_id: user_id)
    }

    scope :notification_exists, lambda { |user_id, consultation_id, type|
        return all unless user_id.present?
        where(user_id: user_id, consultation_id: consultation_id, notification_type: type)
    }
    
    def create_notification(user_id, consultation_id, type)
        self.user_id = user_id
        self.consultation_id = consultation_id
        self.notification_type = type
        self.notification_status = false
        self.save!
    end

    # def check_up_votes(user_id, notification_type)
    #     up_vote_notification_string = Hash.new
    #     up_vote_consultation_list = ::UserNotification.up_vote_filter(user_id, 'RESPONSE_UPVOTE')
    #     if up_vote_consultation_list.exists?
    #         up_vote_main_text =  ::NotificationType.get_main_text('RESPONSE_UPVOTE')
	# 	    up_vote_sub_text =  ::NotificationType.get_sub_text('RESPONSE_UPVOTE')
    #         up_vote_consultation_list = ::UserNotification.up_vote_filter(user_id, 'RESPONSE_UPVOTE')
    #         up_vote_notification_string["type"] = "RESPONSE_UPVOTE"
    #         up_vote_notification_string["up_vote_main_text"] = up_vote_main_text[0]
    #         up_vote_notification_string["up_vote_sub_text"] = up_vote_sub_text[0]
    #         up_vote_notification_string["up_vote_consultation_list"] = up_vote_consultation_list
    #         return up_vote_notification_string
    #     end
    # end

    def check_notification(user_id, notification_type)
        notification_string = Hash.new
        consultation_list = ::UserNotification.notification_filter(user_id, notification_type)
        if consultation_list.exists?
            main_text =  ::NotificationType.get_main_text(notification_type)
		    sub_text =  ::NotificationType.get_sub_text(notification_type)
            notification_string["type"] = notification_type
            notification_string["main_text"] = main_text[0]
            notification_string["sub_text"] = sub_text[0]
            notification_string["consultation_list"] = consultation_list
            return notification_string
        end
    end
end
