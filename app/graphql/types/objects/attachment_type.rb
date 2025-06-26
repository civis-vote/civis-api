module Types
  module Objects
    class AttachmentType < BaseObject
      field :id, String, null: true
      field :filename, String, null: true
      field :url, String, null: true

      def id
        object.instance_of?(Hash) ? object["id"] : (object.respond_to?(:id) ? object.id : nil)
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
