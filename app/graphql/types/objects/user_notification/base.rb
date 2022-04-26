module Types
    module Objects
        module UserNotification
            class Base < Types::BaseObject
                graphql_name "BaseUserNotificationType"
                field :user_id, Integer, nil, null: false
                field :notification_details, String, nil, null: false
                field :type, String, nil , null: false
                field :oldrank, Integer, nil,   null: false
                field :status, Boolean, nil, null: false
            end
        end
    end
end