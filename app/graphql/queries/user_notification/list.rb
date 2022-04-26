module Queries
	module UserNotification
		class List < Queries::BaseQuery
            description "Get a list of user notifications"
            argument :page,							Int,		required: false, default_value: 1
            argument :per_page,					Int,		required: false, default_value: 20
            argument :user_id,		String, required: false, default_value: nil

            type Types::Objects::UserNotification::List, null: true

            def resolve(user_id:, per_page:, page:)
                ::UserNotification.user_id_filter(user_id).list(per_page, page)
            end
		end
	end
end