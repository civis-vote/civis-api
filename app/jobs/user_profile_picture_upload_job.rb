class UserProfilePictureUploadJob < ApplicationJob
  queue_as :default

  def perform(user, image)
  	file = open(image)
  	user.profile_picture.attach(io: file, filename: user.first_name) if file.present?
  end
end