Types::Inputs::MinistryInput = GraphQL::InputObjectType.define do
  name 'MinistryInput'

  argument :category_id,     			types.Int
  argument :cover_photo_file,			Types::Inputs::AttachmentInput
  argument :level,            		types.String, '["national", "state", "local"]'
  argument :logo_file,						Types::Inputs::AttachmentInput
	argument :name,             		types.String
  argument :poc_email_primary,		types.String
  argument :poc_email_secondary,	types.String

end
