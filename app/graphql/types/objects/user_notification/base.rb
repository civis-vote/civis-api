module Types
    module Objects
        module UserNotification
            class Base < Types::BaseObject
                graphql_name "BaseUserNotificationType"
                field :id, Integer, nil, null:false
                field :user_id, Integer, nil, null: false
                field :notification_type, String, nil , null: false
                field :notification_status, Boolean, nil, null: false
            end
        end
    end
end