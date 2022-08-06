class NotificationType < ApplicationRecord
    include SpotlightSearch
    include Paginator

    scope :get_main_text, lambda { |notification_type|
        return all unless notification_type.present?
        where(notification_type: notification_type).pluck(:notification_main_text)
    }
    
    scope :get_sub_text, lambda { |notification_type|
        return all unless notification_type.present?
        where(notification_type: notification_type).pluck(:notification_sub_text)
    }

    scope :search_notification_type, lambda { |query = nil|
      return nil unless query
      where("notification_type ILIKE (?)", "%#{query}%")
    }
end
