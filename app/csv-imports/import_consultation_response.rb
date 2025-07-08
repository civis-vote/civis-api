class ImportConsultationResponse
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
        consultation_response = ::ConsultationResponse.new
        consultation_response.import_key = sanitize_column_value(row['import_key'])
        consultation_response.consultation_id = sanitize_column_value(row['consultation_id'])
        consultation_response.first_name = sanitize_column_value(row['first_name'])
        consultation_response.last_name = sanitize_column_value(row['last_name'])
        consultation_response.email = sanitize_column_value(row['email'])
        consultation_response.phone_number = sanitize_column_value(row['phone_number'])
        if sanitize_column_value(row['responded_at']).present?
          consultation_response.responded_at = Date.parse(sanitize_column_value(row['responded_at']))
        end
        consultation_response.organisation_id = sanitize_column_value(row['organisation_id'])
        consultation_response.visibility = sanitize_column_value(row['visibility'])
        consultation_response.satisfaction_rating = sanitize_column_value(row['satisfaction_rating'])
        consultation_response.response_text = sanitize_column_value(row['response_text'])
        consultation_response.source = 'off_platform'
        answer_hash = get_question_id_with_answers_hash(row.to_h.with_indifferent_access)
        consultation_response.answers = answer_hash['answers']
        consultation_response.response_round_id = answer_hash['response_round_id']
        consultation_response.user_id = answer_hash['user_id']

        if consultation_response.valid?
          consultation_response.save!
        else
          @invalid_rows << OpenStruct.new({ line_number: index + 2, identifier: consultation_response.id,
                                            errors: consultation_response.errors.message })
        end
      rescue StandardError => e
        @invalid_rows << OpenStruct.new({ line_number: index + 2, identifier: "", errors: { error: e.message } })
      end
    end
  end

  def non_question_id_headers
    %w[import_key consultation_id first_name last_name email phone_number responded_at organisation_id visibility
       satisfaction_rating response_text]
  end

  def get_question_id_with_answers_hash(hash)
    consultation = Consultation.find(hash['consultation_id'])
    response_rounds = consultation.response_rounds.order(:created_at)
    response_round_id = response_rounds.last.id
    questions = response_rounds.last.questions
    email = hash['email']
    user = User.find_by(email:)

    answers = []

    response_hash = {}.with_indifferent_access

    hash.each do |key, value|
      next unless non_question_id_headers.exclude?(key) && value.present?

      question_id = key.to_i
      question = questions.find_by(id: question_id)
      next unless question.present?

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
      answer_in_hash.merge!(other_option_answer: value, "is_other": 'true') if other_option_answer && question.supports_other
      answers << answer_in_hash
    end
    answers = nil if answers == []
    response_hash['answers'] = answers
    response_hash['response_round_id'] = response_round_id
    response_hash['user_id'] = user.id if user
    response_hash
  end

  def sanitize_column_value(value)
    value&.strip.presence
  end
end
