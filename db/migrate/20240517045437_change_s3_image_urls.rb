class ChangeS3ImageUrls < ActiveRecord::Migration[7.1]
  def change
    def updated_rich_text(rich_text)
      return nil if rich_text.blank?

      regex = %r{https://civis-production-api\.s3\.ap-south-1\.amazonaws\.com/[^"?]*\?[^"]*}
      rich_text.gsub(regex) do |url|
        url.split('?').first
      end
    end

    Consultation.all.each do |ct|
      english_string = ct.english_summary.to_s
      hindi_string = ct.hindi_summary.to_s
      ct.update(english_summary: updated_rich_text(english_string), hindi_summary: updated_rich_text(hindi_string))
    end
  end
end
