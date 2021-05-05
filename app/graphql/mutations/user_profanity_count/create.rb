module Mutations
    module UserProfanityCount
      class Create < Mutations::BaseMutation
        type Types::Objects::UserProfanityCount, null: false
  
        argument :user_id, Types::Inputs::UserProfanityCount::Create, required: true
        argument :profanity_count, Types::Inputs::UserProfanityCount::Create, required: true
        def resolve(user_id:,profanity_count:)
          current_user = ::UserProfanityCount.new user_id.to_h
          current_user.update_attributes! profanity_count.to_h
          return current_user_id
        end
  
        def self.authorized?(object, context)
          context[:current_user_id].present?
        end
      end
    end
  end
