module Mutations
  module UserNotification
    class Update < Mutations::BaseMutation

      type Types::Objects::UserNotification::Base, null: false

      description "User Notification status to be marked as read for a given notification id"
	    argument :notification_id,		Int,		required: true

      def resolve(notification_id:)
        user_notification = ::UserNotification.find_by(id: notification_id)
        user_notification.update(notification_status: true)

        if user_notification.notification_type = 'LEADERBOARD_UPDATE'
          ::User.where(id: user_notification.user_id).update(welcome_notification: true)
        end

        return user_notification
      end
    end
  end
end