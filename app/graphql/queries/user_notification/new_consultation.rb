module Queries
    module UserNotification
        class NewConsultation < Queries::BaseQuery
            description "Notification for newly created consultation"
            argument :user_id,		Int,		required: false, default_value: nil
            argument :page,							Int,		required: false, default_value: 1
	        argument :per_page,					Int,		required: false, default_value: 20
            type Types::Objects::Consultation::List, null: true
    
            def resolve(user_id:, per_page:, page:)
                user_last_login = ::User.lastlogin(user_id)
                ::Consultation.public_consultation.published_date_filter(user_last_login).list(per_page, page)
            end
        end
    end
end