module Mutations
  module UserCount
    class Create < Mutations::BaseMutation
      type Types::Objects::UserCount::Base, null: false
      argument :user_count, Types::Inputs::UserCount::Create, required: true
      def resolve(user_count:)
        newCountMapping = ::UserCount.new user_count.to_h
        newCountMapping.user_id = user_count.user_id
        newCountMapping.profanity_count = user_count.profanity_count
        newCountMapping.short_response_count = user_count.short_response_count
        newCountMapping.save!
        return newCountMapping
      end
    end
  end
end