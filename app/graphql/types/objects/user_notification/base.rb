# module Types
#     module Objects
#         module UserNotification
#             class Base < Types::BaseObject
#                 graphql_name "BaseUserNotificationType"
#                 field :user_id, Integer, nil, null: false
#                 field :consultation_id, Integer, nil, null: false
#                 field :notification_type, String, nil , null: false
#                 field :notification_details, String, nil, null: false
#                 field :old_rank, Integer, nil,   null: false
#             end
#         end
#     end
# end