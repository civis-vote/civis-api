class UserNotification < ApplicationRecord
    include SpotlightSearch
    include Paginator

    scope :user_id_filter, lambda { |user_id|
        return all unless user_id.present?
        where(user_id: user_id, notification_status: 0)
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
        # notification_text = ""
        # case
        #     when type == "RESPONSE_UPVOTE"
        #         notification_text = "Your response has been upvoted"
        #     when type == "RESPONSE_USED"
        #         notification_text = "Your response has been used"
        # end
        # self.notification_details = notification_text
        self.user_id = user_id
        self.consultation_id = consultation_id
        self.notification_type = type
        self.notification_status = false
        self.save!
    end
end
