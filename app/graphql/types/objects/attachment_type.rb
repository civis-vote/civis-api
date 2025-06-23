module Types
  module Objects
    class AttachmentType < BaseObject
      field :id, String, null: false
      field :filename, String, null: true
      field :url, String, null: true

      def id
        object.instance_of?(Hash) ? object["id"] : object.id
      end

      def filename
        object.instance_of?(Hash) ? object["filename"] : object.filename.to_s
      end

      def url
        object.instance_of?(Hash) ? object["url"] : object.url
      end
    end
  end
end
