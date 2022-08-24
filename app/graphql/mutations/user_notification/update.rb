module Mutations
  module UserNotification
    class Update < Mutations::BaseMutation

      type Types::Objects::UserNotification::Base, null: false

      description "User Notification status to be marked as read for a given notification id"
	    argument :notification_id,		Int,		required: true

      def resolve(notification_id:)
        user_notification = ::UserNotification.find_by(id: notification_id)
        user_notification.update(notification_status: true)
        return user_notification
      end
    end
  end
end