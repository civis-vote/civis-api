Types::Objects::AttachmentType = GraphQL::ObjectType.define do
  name "AttachmentType"

  field :id,                  types.Int do 
    resolve ->(obj, _, _){
      if obj.class.eql?(ActiveStorage::Variant)
        obj.blob.id
      else
        obj.id
      end
    }
  end
  field :filename,            types.String do 
    resolve ->(obj, _, _){
      if obj.class.eql?(ActiveStorage::Variant)
        obj.blob.filename.to_s + "-" +obj.variation.transformations[:resize]
      else
        obj.filename.to_s
      end
    }
  end
  field :url,                 types.String do
    resolve ->(obj, _, _) {
      if obj.class.eql?(ActiveStorage::Variant)
        Rails.application.routes.url_helpers.rails_representation_url(obj)
      else
        Rails.application.routes.url_helpers.rails_blob_url(obj)
      end
    }
  end
end