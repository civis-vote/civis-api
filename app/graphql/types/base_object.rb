module Types
  class BaseObject < GraphQL::Schema::Object
    def attachment_with_resolution(attachment_name, resolution)
      width, height = resolution&.split("x")&.map(&:to_i)
      attachment = object.public_send(attachment_name)

      return unless attachment.attached?

      return attachment if width.blank? || height.blank?

      attachment.variant(resize_to_limit: [width, height]).processed
    end
  end
end
