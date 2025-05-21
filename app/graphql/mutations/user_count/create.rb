module Mutations
  module UserCount
    class Create < Mutations::BaseMutation
      type Types::Objects::UserCount::Base, null: false
      argument :user_count, Types::Inputs::UserCount::Create, required: true
      def resolve(user_count:)
        new_count_mapping = ::UserCount.find_or_create_by(user_id: user_count.user_id) do |record|


          record.profanity_count = user_count.profanity_count
          record.short_response_count = user_count.short_response_count
        end

        # Update the fields if the record already exists
        new_count_mapping.update!(
          profanity_count: user_count.profanity_count,
          short_response_count: user_count.short_response_count
        )

        new_count_mapping
      end
    end
  end
end