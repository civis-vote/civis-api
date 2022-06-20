module ImportGlossary
  extend ActiveSupport::Concern
  require 'roo'
  require 'roo-xls'

  module ClassMethods
    def import_fields_from_files(object,user_id)
      begin
        result = {}
        file = csv_parse(object)
        headers = set_headers(file)
        required_headers = set_required_headers
        missing_headers =  missing_headers(required_headers, headers)
        if missing_headers.present?
          p " -------------- Missing headers ------------ "
          p missing_headers
        else
          records = []
          file.each_with_index do |row, index|
            hash = row.to_h
            new_hash = customized_hash_from_rows(hash)
            new_hash.merge!({"created_by_id": user_id})
            word_value = new_hash["word"]
            word = Wordindex.find_by(word: word_value)
            if word.present?
              Wordindex.delete(word.id)
            end
            records << new_hash
          end
          import_records(records) if records.present?
          return result.merge!(status: "true", records_count: records.size)
        end
      rescue Exception => e
        Rollbar.error(e)
        return result.merge!(status: "false")
      end
    end

    def csv_parse(file)
      byebug
      content_type = File.extname(file.original_filename.to_s)
      if content_type.include?('csv')
        csv_file = open(file.path)
        csv_file = csv_file.string rescue csv_file.read
        csv_file = csv_file.encode("UTF-8", "Windows-1252").sub("\xEF\xBB\xBF", '')
      else
        begin
          xlsx = Roo::Spreadsheet.open(file.path, extension: :xlsx)
        rescue Zip::Error
          xlsx = Roo::Spreadsheet.open(file.path, extension: :xls)
        end
        begin
          xlsx.default_sheet = 'Import Data'
        rescue
          xlsx.default_sheet = xlsx.sheets.last
        end 
        csv_file = xlsx.to_csv
      end
      file = CSV.parse(csv_file, headers: true)
    end

    def set_headers(file)
      file.headers.reject(&:blank?)
    end

    def missing_headers(required_headers, headers)
      required_headers - headers
    end

    def set_required_headers
      required_headers = ["word", "description"]
    end

    def customized_hash_from_rows(hash)
      hash.each do |key, value|
        if !(value.nil?)
          stripped_value = value.strip
          hash[key] = stripped_value
        end
      end
      return hash
    end

    def import_records(records)
      ActiveRecord::Base.transaction do
        self.create!(records)
      end
    end
  end
end
