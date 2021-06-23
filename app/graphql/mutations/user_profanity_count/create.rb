module Mutations
  module UserProfanityCount
    class Create < Mutations::BaseMutation
    type Types::Objects::UserProfanityCount::Base, null: false
    argument :user_profanity_count, Types::Inputs::UserProfanityCount::Create, required: true
    def resolve(user_profanity_count:)
      newProfaneCountMapping = ::UserProfanityCount.new user_profanity_count.to_h
      newProfaneCountMapping.user_id = user_profanity_count.user_id
      newProfaneCountMapping.profanity_count = user_profanity_count.profanity_count 
      newProfaneCountMapping.save!
      return newProfaneCountMapping
      end
    end
  end
end
