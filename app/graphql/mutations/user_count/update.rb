module Mutations
  module UserCount
    class Update < Mutations::BaseMutation
      type Types::Objects::UserCount::Base, null: false

      argument :user_count, Types::Inputs::UserCount::Create, required: true
      def resolve(user_count:)
        currentCountMapping = ::UserCount.find_by(user_id:user_count.user_id)
        currentCountMapping.update!(profanity_count: user_count[:profanity_count])
        currentCountMapping.update!(short_response_count: user_count[:short_response_count])
        return currentCountMapping
      end
    end
  end
end
