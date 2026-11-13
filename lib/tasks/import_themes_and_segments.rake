namespace :import_records_from_array do

  task :themes_and_segments => :environment do
    ::Theme::CIVIS_THEMES.each do |name, icon_name|
      theme = ::Theme.with_deleted.find_or_initialize_by(name: name)
      theme.restore if theme.deleted?
      theme.icon_name ||= icon_name
      theme.status = :active
      theme.save!
    end

    # Disable every non-canonical theme left over from the legacy taxonomy.
    disabled = ::Theme.where.not(name: ::Theme::CIVIS_THEME_NAMES).update_all(status: ::Theme.statuses[:disabled])

    ::Constant::SEGMENT_NAMES.each { |name| ::Constant.find_or_create_by!(name: name, constant_type: :segment) }

    puts "Themes: #{::Theme.count} total (#{disabled} legacy themes disabled)"
    puts "Segments: #{::Constant.where(constant_type: :segment).count} total"
  end

end
