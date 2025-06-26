namespace :migrate do
  desc "Migrate Shrine attachments to Active Storage"
  task shrine_attachments_to_active_storage: :environment do
    Category.find_each do |category|
      next unless category.cover_photo_data

      shrine_file = Shrine::UploadedFile.new(JSON.parse(category.cover_photo_data))
      io = shrine_file.download
      category.cover_photo.attach(
        io: io,
        filename: shrine_file.original_filename,
        content_type: shrine_file.mime_type
      )
      puts "Migrated category #{category.id}"
    end

    Ministry.find_each do |ministry|
      next unless ministry.logo_data

      shrine_file = Shrine::UploadedFile.new(JSON.parse(ministry.logo_data))
      io = shrine_file.download
      ministry.logo.attach(
        io: io,
        filename: shrine_file.original_filename,
        content_type: shrine_file.mime_type
      )
      puts "Migrated ministry #{ministry.id}"
    end

    User.find_each do |user|
      next unless user.profile_picture_data

      shrine_file = Shrine::UploadedFile.new(JSON.parse(user.profile_picture_data))
      io = shrine_file.download
      user.profile_picture.attach(
        io: io,
        filename: shrine_file.original_filename,
        content_type: shrine_file.mime_type
      )
      puts "Migrated user #{user.id}"
    end

    Organisation.find_each do |organisation|
      next unless organisation.logo_data

      shrine_file = Shrine::UploadedFile.new(JSON.parse(organisation.logo_data))
      io = shrine_file.download
      organisation.logo.attach(
        io: io,
        filename: shrine_file.original_filename,
        content_type: shrine_file.mime_type
      )
      puts "Migrated organisation #{organisation.id}"
    end
  end
end
