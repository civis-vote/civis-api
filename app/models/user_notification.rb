class UserNotification < ApplicationRecord
    include SpotlightSearch
    include Paginator

    scope :user_id_filter, lambda { |user_id|
        return all unless user_id.present?
        where(user_id: user_id)
}
    scope :consultation_id_filter, lambda { |consultation_id, user_id|
        return all unless user_id.present?
        where(oldrank: consultation_id, user_id: user_id)
    }
    def create_notification(notification_text,user_id)
        self.notification_details = notification_text
        self.user_id = user_id
        self.status = false
        self.save!
    end



end
