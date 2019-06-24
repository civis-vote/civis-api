Queries::CurrentUserQueryType = GraphQL::InterfaceType.define do
  name "CurrentUserQueryType"

  field :currentUser, Types::Objects::User::CurrentUserType do
    resolve ->(_, args, ctx) {
      Current.user
    }
  end
end