module ImportResponse
  extend ActiveSupport::Concern
  require 'roo'
  require 'roo-xls'

  module ClassMethods
    def import_fields_from_files(object)
      result = {}
      file = csv_parse(object)
      headers = set_headers(file)
      required_headers = set_required_headers
      missing_headers =  missing_headers(required_headers, headers)
      if missing_headers.present?
        p ' -------------- Missing headers ------------ '
        p missing_headers
      else
        records = []
        file.each_with_index do |row, _index|
          hash = row.to_h
          hash = customized_hash_from_rows(hash)
          records << hash
        end
        import_records(records) if records.present?
        result.merge!(status: 'true', records_count: records.size)
      end
    rescue Exception => e
      Airbrake.notify_sync(e)
      result.merge!(status: 'false')
    end

    def csv_parse(file)
      content_type = File.extname(file.original_filename.to_s)
      if content_type.include?('csv')
        csv_file = open(file.path)
      else
        begin
          xlsx = Roo::Spreadsheet.open(file.path, extension: :xlsx)
        rescue Zip::Error
          xlsx = Roo::Spreadsheet.open(file.path, extension: :xls)
        end
        begin
          xlsx.default_sheet = 'Import Data'
        rescue StandardError
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
      required_headers = %w[import_key consultation_id first_name last_name email phone_number responded_at organisation_id visibility satisfaction_rating response_text]
    end

    def customized_hash_from_rows(hash)
      consultation = Consultation.find(hash['consultation_id'])
      response_rounds = consultation.response_rounds.order(:created_at)
      response_round_id = response_rounds.last.id
      questions = response_rounds.last.questions
      email = hash['email']
      user = User.find_by(email:)
      answers = []
      hash.each do |key, value|
        if !set_required_headers.include?(key) && value.present?
          question_id = key.to_i
          question = questions.find_by(id: question_id)
          if question.present?
            question_id = question.id.to_s
            question_type = question.question_type
            sub_questions = question.sub_questions
            if question_type == 'long_text'
              answer = value
            elsif question_type == 'checkbox'
              begin
                answer = value.split(',').map { |mc_ans| sub_questions.find_by(question_text: mc_ans.strip).id.to_s }
              rescue StandardError
                other_option_answer = value
              end
            else
              answer = nil
              answer = sub_questions.find_by(question_text: value) if value.present?
              answer = answer.id if answer.present?
              other_option_answer = value unless answer.present?
            end
            answer_in_hash = { "answer": answer, "question_id": question_id }
            answer_in_hash.merge!(other_option_answer: value, "is_other": 'true') if other_option_answer && question.supports_other == true
            answers << answer_in_hash
          end
        end
        hash.delete key unless set_required_headers.include?(key)
      end
      answers = nil if answers == []
      hash = hash.transform_keys { |key| key.parameterize.underscore }
      hash.merge!({ "response_round_id": response_round_id })
      hash.merge!({ "user_id": user.id }) if user
      hash.merge!({ "answers": answers })
      hash.merge!({ 'source': 'off_platform' })
      hash
    end

    def import_records(records)
      ActiveRecord::Base.transaction do
        create!(records)
      end
    end
  end
end
