module Attachable
  extend ActiveSupport::Concern

  included do
  end

  def save_attachment_with_base64(attachment_name, content, filename)
    base64_content = Base64.decode64(content.to_s)
    attachment = send(attachment_name)
    attachment.attach(io: StringIO.new(base64_content), filename: filename.to_s)
  end
end
