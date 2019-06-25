Types::Inputs::AttachmentInput = GraphQL::InputObjectType.define do
  name 'AttachmentInput'

  argument :filename,   				types.String 
  argument :content,    				types.String

end