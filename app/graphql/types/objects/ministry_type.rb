Types::Objects::MinistryType = GraphQL::ObjectType.define do
  name "MinistryType"

  field :id,                	types.Int
  field :category,				Types::Objects::ConstantType
  field :cover_photo,       	Types::Objects::AttachmentType do 
    argument :resolution,                 types.String
    resolve ->(obj, args, _) {
      obj.resize(args[:resolution], "cover_photo")
    }
  end
  field :level,					Types::Enum::MinistryLevel
  field :logo,       Types::Objects::AttachmentType do 
    argument :resolution,                 types.String
    resolve ->(obj, args, _) {
      obj.resize(args[:resolution], "logo")
    }
  end
  field :name,              	types.String
  field :poc_email_primary, 	types.String
  field :poc_email_secondary, 	types.String
end