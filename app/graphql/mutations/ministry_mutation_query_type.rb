Mutations::MinistryMutationQueryType = GraphQL::InterfaceType.define do
  name "MinistryMutationQuery"

  field :ministryCreate,                     Types::Objects::MinistryType do
    description "Create an unapproved ministry"
    argument :ministry,                      Types::Inputs::MinistryInput
    resolve ->(_, args, _) {
      ministry = Ministry.new args[:ministry].to_h
      ministry.created_by = Current.user
      ministry.save_with_attachments
      return ministry
    }
  end
end