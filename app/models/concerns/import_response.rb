module ImportResponse
  extend ActiveSupport::Concern
  require 'roo'
  require 'roo-xls' 

  module ClassMethods
    def import_fields_from_files(object)
      begin
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
            hash = customized_hash_from_rows(hash)
            records << hash
          end
          import_records(records) if records.present?
        end
      rescue Exception => e
        Rollbar.error(e)
        return false
      end
    end

    def csv_parse(file)
      content_type = File.extname(file.original_filename.to_s)
      if content_type.include?('csv')
        csv_file = open(file.path)
        csv_file = csv_file.string rescue csv_file.read
        csv_file = csv_file.force_encoding("UTF-8").sub("\xEF\xBB\xBF", '')
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
      required_headers = ["import_key", "consultation_id", "first_name", "last_name", "email", "phone_number", "responded_at", "visibility", "satisfaction_rating"]
    end

    def customized_hash_from_rows(hash)
      hash = hash.transform_keys { |key| key.downcase.parameterize.underscore }
      consultation = Consultation.find(hash["consultation_id"])
      response_rounds = consultation.response_rounds.order(:created_at)
      response_round_id = response_rounds.last.id
      questions = response_rounds.last.questions
      hash.merge!({"response_round_id": response_round_id})
      hash.delete "product_interest"
      email = hash["email"]
      user = User.find_by(email: email)
      hash.merge!({"user_id": user.id}) if user && email
      answers = []
      hash.each do |key, value|
        if (key.to_s.include? 'question') && (value.present?)
          value = JSON.parse(value)
          question = questions.find_by(question_text: value["question"].strip)
          if question.present?
            question_id = question.id.to_s
            question_type = question.question_type
            sub_questions = question.sub_questions
            if question_type == "long_text"
              answer = value["answer"]
            elsif value["answer"].class == Array
              answer = value["answer"].map{|mc_ans| sub_questions.find_by(question_text: mc_ans.strip).id.to_s}
            else
              answer = nil
              answer = sub_questions.find_by(question_text: value["answer"].strip) if value["answer"].present?
              answer = answer.id if answer.present?
            end
            answer_in_hash = {"answer": answer, "question_id": question_id}
            answer_in_hash.merge!(other_option_answer: value["other_option_answer"], "is_other": "true") if value["other_option_answer"].present?
            answers << answer_in_hash
          end
        end
        hash.delete key if key.to_s.include? 'question'
      end
      hash.merge!({"answers": answers})
      return hash
    end

    def import_records(records)
      ActiveRecord::Base.transaction do
        self.create!(records)
      end
    end
  end
end
