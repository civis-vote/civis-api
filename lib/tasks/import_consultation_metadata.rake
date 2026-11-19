require "roo"

# Imports the Themes and Segments taxonomy columns from the consultation
# metadata export (Consultation_data_updated_2026-10-22.xlsx), for every
# consultation in Sheet1.
#
# The export itself is a CM Admin snapshot; this task only writes the theme
# and segment tags — it never touches titles, summaries, deadlines, etc.
#
# Usage:
#   # Pre-flight check (default, writes nothing)
#   bundle exec rails import_records_from_xlsx:consultation_metadata
#
#   # Perform the import
#   bundle exec rails import_records_from_xlsx:consultation_metadata APPLY=1
#
# Options:
#   FILE=/path/to/file.xlsx   override the source file (default: imports/consultation_data_updated_2026-10-22.xlsx)
#   APPLY=1                   write changes (without it the task only reports)
namespace :import_records_from_xlsx do

  desc "Import themes and segments from the consultation metadata export"
  task consultation_metadata: :environment do
    filepath = ENV["FILE"].presence || Rails.root.join("imports", "consultation_data_updated_2026-10-22.xlsx")
    apply = ENV["APPLY"] == "1"

    unless File.exist?(filepath)
      puts "ERROR: Source file not found at #{filepath}"
      puts "       Pass FILE=/path/to/file.xlsx or drop the file at imports/consultation_data_updated_2026-10-22.xlsx"
      exit 1
    end

    unless ActiveRecord::Base.connection.table_exists?(:theme_maps)
      puts "ERROR: theme_maps table does not exist in this database."
      puts "       The production dump predates the themes work; run `bundle exec rails db:migrate` first."
      exit 1
    end

    puts "Source: #{filepath}"
    puts "Mode:   #{apply ? 'APPLY (writes changes)' : 'DRY RUN (no changes written)'}"
    puts ""

    rows = read_rows(filepath)
    puts "Excel rows: #{rows.size}"
    puts ""

    # ------------------------------------------------------------------
    # Lookups
    # ------------------------------------------------------------------
    theme_by_normalized = ::Theme::CIVIS_THEME_NAMES.index_by { |n| normalize(n) }
    segment_by_normalized = ::Constant::SEGMENT_NAMES.index_by { |n| normalize(n) }

    consultations = ::Consultation.where(id: rows.map { |r| r[:consultation_id] }).index_by(&:id)
    existing_themes = ::Theme.all.index_by(&:name)
    existing_segments = ::Constant.where(constant_type: :segment).group_by { |c| normalize(c.name) }

    # ------------------------------------------------------------------
    # Pre-flight validations (always reported)
    # ------------------------------------------------------------------
    missing_consultations = rows.map { |r| r[:consultation_id] } - consultations.keys
    puts "VALIDATION:"
    puts "  Consultations in Excel missing from DB: #{missing_consultations.size}"
    missing_consultations.first(10).each { |id| puts "    id #{id} does not exist" }

    unknown_themes = rows.flat_map { |r| r[:theme_names] }.uniq.reject { |n| theme_by_normalized[normalize(n)] }
    puts "  Theme values not in CIVIS_THEME_NAMES: #{unknown_themes.size} -> #{unknown_themes.inspect}"

    unknown_segments = rows.flat_map { |r| r[:segment_names] }.uniq.reject { |n| segment_by_normalized[normalize(n)] }
    puts "  Segment values not in CIVIS_SEGMENT_NAMES: #{unknown_segments.size} -> #{unknown_segments.inspect}"

    puts "  Rows with blank Themes: #{rows.count { |r| r[:theme_names].empty? }}"
    puts "  Rows with blank Segments: #{rows.count { |r| r[:segment_names].empty? }}"
    puts ""

    # ------------------------------------------------------------------
    # Plan
    # ------------------------------------------------------------------
    themes_to_create = ::Theme::CIVIS_THEME_NAMES.reject { |n| existing_themes[n] }
    segments_to_create = ::Constant::SEGMENT_NAMES.reject { |n| existing_segments[normalize(n)] }

    theme_map_changes = rows.sum do |r|
      cons = consultations[r[:consultation_id]]
      next 0 unless cons

      desired = r[:theme_names].filter_map { |n| theme_by_normalized[normalize(n)] }
                .map { |n| existing_themes[n] || ::Theme.new(name: n) }
      (desired.map(&:id) - cons.themes.pluck(:id)).size + (cons.themes.pluck(:id) - desired.map(&:id)).size
    end
    segment_map_changes = rows.sum do |r|
      cons = consultations[r[:consultation_id]]
      next 0 unless cons

      desired = r[:segment_names].filter_map { |n| segment_by_normalized[normalize(n)] }
                .map { |n| existing_segments[normalize(n)]&.first || ::Constant.new(name: n) }
      (desired.map(&:id) - cons.segments.pluck(:id)).size + (cons.segments.pluck(:id) - desired.map(&:id)).size
    end

    puts "PLAN:"
    puts "  Themes to create:   #{themes_to_create.size}"
    puts "  Segments to create: #{segments_to_create.size}"
    puts "  Theme map rows to add/remove:   #{theme_map_changes}"
    puts "  Segment map rows to add/remove: #{segment_map_changes}"
    puts ""

    if apply
      # ------------------------------------------------------------------
      # Apply
      # ------------------------------------------------------------------
      ActiveRecord::Base.transaction do
      themes_to_create.each do |n|
        theme = ::Theme.with_deleted.find_by(name: n)
        if theme
          theme.restore
          theme.update!(icon_name: ::Theme::CIVIS_THEMES[n]) if theme.icon_name.blank?
        else
          theme = ::Theme.create!(name: n, icon_name: ::Theme::CIVIS_THEMES[n])
        end
        existing_themes[n] = theme
      end
      segments_to_create.each { |n| existing_segments[normalize(n)] = [::Constant.create!(name: n, constant_type: :segment)] }

      rows.each do |row|
        cons = consultations[row[:consultation_id]]
        next unless cons

        # Themes
        desired_themes = row[:theme_names].filter_map { |n| existing_themes[theme_by_normalized[normalize(n)]] }
        cons.theme_maps.where.not(theme_id: desired_themes.map(&:id)).destroy_all
        desired_themes.each do |theme|
          ::ThemeMap.find_or_create_by!(theme: theme, mappable: cons)
        end

        # Segments
        desired_segments = row[:segment_names].filter_map { |n| existing_segments[normalize(n)]&.first }
        cons.constant_maps.joins(:constant)
            .where(constants: { constant_type: :segment })
            .where.not(constant_id: desired_segments.map(&:id)).destroy_all
        desired_segments.each do |segment|
          ::ConstantMap.find_or_create_by!(constant: segment, mappable: cons)
        end
      end
      end

      puts "IMPORT COMPLETE"
      puts "  Themes:   #{::Theme.count} total"
      puts "  Segments: #{::Constant.where(constant_type: :segment).count} total"
      puts "  ThemeMaps:   #{::ThemeMap.where(mappable_type: 'Consultation').count}"
      puts "  Segment maps: #{::ConstantMap.joins(:constant).where(mappable_type: 'Consultation', constants: { constant_type: :segment }).count}"
    end
  end

  # --------------------------------------------------------------------

  def read_rows(filepath)
    sheet = Roo::Spreadsheet.open(filepath.to_s).sheet("Sheet1")
    headers = sheet.row(1).map(&:to_s)

    rows = []
    (2..sheet.last_row).each do |i|
      row = Hash[headers.zip(sheet.row(i))]

      next if row["Id"].nil? # skip blank trailing rows

      rows << {
        consultation_id: row["Id"].to_i,
        theme_names: split_cell(row["Themes"]),
        segment_names: split_cell(row["Segments"])
      }
    end
    rows
  end

  def split_cell(value)
    return [] if value.blank?

    value.to_s.split(";").map(&:strip).reject(&:empty?)
  end

  def normalize(value)
    value.to_s.strip.gsub(/[\u2018\u2019]/, "'").downcase
  end
end