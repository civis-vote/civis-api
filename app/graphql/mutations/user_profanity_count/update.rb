module Mutations
  module UserProfanityCount
  class Update < Mutations::BaseMutation
      type Types::Objects::UserProfanityCount::Base, null: false

    argument :user_profanity_count, Types::Inputs::UserProfanityCount::Create, required: true
    def resolve(user_profanity_count:)
      currentProfaneCountMapping = ::UserProfanityCount.find_by(user_id:user_profanity_count.user_id)
      currentProfaneCountMapping.update!(profanity_count: user_profanity_count[:profanity_count])
      return currentProfaneCountMapping
      end
    end
  end
end
