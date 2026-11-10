namespace :import_records_from_array do

  task :themes_and_segments => :environment do
    ::CIVIS_THEME_NAMES.each { |name| ::Theme.find_or_create_by!(name: name) }
    ::CIVIS_SEGMENT_NAMES.each { |name| ::Constant.find_or_create_by!(name: name, constant_type: :segment) }

    puts "Themes: #{::Theme.count} total"
    puts "Segments: #{::Constant.where(constant_type: :segment).count} total"
  end

end
