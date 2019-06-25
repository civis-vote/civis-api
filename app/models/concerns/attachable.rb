module Attachable
  extend ActiveSupport::Concern

  included do
  end

  def save_with_attachments
    self.save!
    self.save_attachment
  end

  def update_attributes!(args)
    add_accessors_for_attachment_types
    super
    self.save_attachment
  end

  def initialize(args)
    add_accessors_for_attachment_types
    super
  end

  def save_attachment
    self.class.attachment_types.each do |attachment_type|
      if self.send("#{attachment_type}_file").present?
        arr = []
        if self.send("#{attachment_type}_file").class.eql?(Array)
          arr = self.send("#{attachment_type}_file")
        else
          arr << self.send("#{attachment_type}_file")
        end
          arr.each do |x|
            content_type = x["content"][/(image\/[a-z]{3,4})|(application\/[a-z]{3,4})/][/\b(?!.*\/).*/]
            contents = x["content"].sub /data:((image|application)\/.{3,}),/, ''
            decoded_data = Base64.decode64(contents)
            filename = x["filename"]
            File.open("#{Rails.root}/tmp/#{filename}", 'wb') do |f|
              f.write(decoded_data)
            end
            self.send("#{attachment_type}").attach(io: File.open("#{Rails.root}/tmp/#{filename}"), filename: filename, content_type: content_type)
          end
      end
    end
  end

  def attached_url(attachment_type)
    if self.send("#{attachment_type}").attached? && self.send("#{attachment_type}").class == ActiveStorage::Attached::One
      return Rails.application.routes.url_helpers.rails_blob_url(self.send("#{attachment_type}"))
    elsif self.send("#{attachment_type}").attached? && self.send("#{attachment_type}").class == ActiveStorage::Attached::Many
      return self.send("#{attachment_type}")
    else
      return nil
    end
  end

  private

  def add_accessors_for_attachment_types
    self.class.attachment_types.each do |attachment_type|
      singleton_class.class_eval { attr_accessor "#{attachment_type}_file" }
    end
  end
end