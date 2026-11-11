# Assigns segments to consultations whose Segments cell was blank in the
# consultation metadata export (Consultation_data_updated_2026-10-22.xlsx).
# These rows have no segment data in the sheet, so they are handled with an
# id-based map chosen from the consultation title (2026-11-10).
#
# Usage:
#   bundle exec rails segments:assign_consultation_segments
namespace :segments do

  CONSULTATION_TO_SEGMENT_NAMES = {
    1599 => %w[Health\ systems Drugs\ and\ medical\ devices], # Draft National Pharmacy Commission Bill, 2026
    1500 => %w[Pollution\ control Environmental\ impact\ assessment] # Draft notification for creation of Standing Authority
  }.freeze

  desc "Assign segments to consultations that have none in the metadata export"
  task assign_consultation_segments: :environment do
    changed = 0
    missing = 0

    CONSULTATION_TO_SEGMENT_NAMES.each do |consultation_id, segment_names|
      consultation = ::Consultation.find_by(id: consultation_id)
      unless consultation
        missing += 1
        puts "  SKIP: consultation #{consultation_id} not found"
        next
      end

      desired = segment_names.map { |name| ::Constant.find_or_create_by!(name: name, constant_type: :segment) }
      next if consultation.segments.pluck(:id).sort == desired.map(&:id).sort

      consultation.constant_maps.joins(:constant)
                  .where(constants: { constant_type: :segment }).destroy_all
      desired.each do |segment|
        ::ConstantMap.find_or_create_by!(constant: segment, mappable: consultation)
      end
      changed += 1
      puts "  #{consultation_id} -> #{segment_names.join(', ')}"
    end

    puts "Assigned segments to #{changed} consultations (#{CONSULTATION_TO_SEGMENT_NAMES.size - missing - changed} already correct)"
  end

end