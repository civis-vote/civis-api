class ImportWordindex
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
        wordindex = Wordindex.find_or_initialize_by(word: sanitize_column_value(row['word']))
        wordindex.description = sanitize_column_value(row['description'])

        if wordindex.valid?
          wordindex.save!
        else
          @invalid_rows << OpenStruct.new({ line_number: index + 2, identifier: wordindex.id, errors: wordindex.errors.message })
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
