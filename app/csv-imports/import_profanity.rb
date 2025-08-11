class ImportProfanity
  attr_accessor :invalid_rows, :file_path

  def initialize(file_import:)
    @file_import = file_import
    @file_content = @file_import.import_file.download
    @invalid_rows = []
  end

  def run!
    CSV.parse(@file_content, headers: true, encoding: 'utf-8').each_with_index do |row, index|
      puts "Row number - #{index + 1}"
      Current.user = @file_import.added_by
      begin
        profanity = Profanity.find_or_initialize_by(profane_word: sanitize_column_value(row['profane_word']))

        if profanity.valid?
          profanity.save!
        else
          @invalid_rows << OpenStruct.new({ line_number: index + 2, identifier: profanity.id, errors: profanity.errors.message })
        end
      rescue StandardError => e
        @invalid_rows << OpenStruct.new({ line_number: index + 2, identifier: "", errors: { error: e.message } })
      end
    end
  end

  def sanitize_column_value(value)
    value&.strip.presence
  end
end
