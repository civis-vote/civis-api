module Mutations
  module User
    class UnsubscribeConsultation < Mutations::BaseMutation
      type Boolean, null: false

      argument :unsubscribe_token, String, required: true

      def resolve(unsubscribe_token:)
        user = ::User.find_by(uuid: unsubscribe_token)
        raise CivisApi::Exceptions::Unauthorized, "Invalid Unsubscriber Token" unless user
        user.update(notify_for_new_consultation: false)
      end
    end
  end
end