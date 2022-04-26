class UserNotification < ApplicationRecord
    include SpotlightSearch
    include Paginator

    scope :user_id_filter, lambda { |user_id|
        return all unless user_id.present?
        where(user_id: user_id)
}

end
