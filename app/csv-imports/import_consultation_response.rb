class ImportConsultationResponse < CmAdmin::BaseImporter
  required_headers :consultation_id

  NON_QUESTION_ID_HEADERS = %w[import_key consultation_id first_name last_name email phone_number
                               responded_at response_language organisation_id visibility
                               satisfaction_rating response_text].freeze

  SANITIZED_COLUMNS = %w[import_key consultation_id first_name last_name email response_language
                         organisation_id visibility satisfaction_rating response_text].freeze

  def self.use_transaction?
    true
  end

  def import_status
    return :failed if row_count.zero?

    invalid_rows.empty? ? :success : :failed
  end

  def get_question_id_with_answers_hash(hash)
    response_round = latest_response_round(hash['consultation_id'])
    {
      'answers' => hash.filter_map { |key, value| build_answer(response_round.questions, key, value) }.presence,
      'response_round_id' => response_round.id,
      'user_id' => find_user(hash)&.id
    }.with_indifferent_access
  end

  private

  # Every row is validated and saved inside the transaction BaseImporter#run!
  # opens (use_transaction?); if any row failed, everything rolls back.
  def run_import
    seen_row_keys = {}
    each_row do |raw_row, line_number|
      row = sanitize_row(raw_row)
      next if row.each_value.all?(&:blank?)

      @row_count += 1
      collect_row(row, line_number, seen_row_keys)
    end
    raise ActiveRecord::Rollback if invalid_rows.present?
  end

  def collect_row(row, line_number, seen_row_keys)
    response = build_consultation_response(row)
    if duplicate?(response, seen_row_keys)
      puts "Skipping duplicate response on line #{line_number}"
      @success_count += 1
    elsif valid_response?(response)
      response.save!
      @success_count += 1
      seen_row_keys[dedup_key(response)] = true
    else
      report_error(line_number, identifier_for(row), response.errors.full_messages.join(', '))
    end
  rescue StandardError => e
    report_error(line_number, identifier_for(row), e.message)
  end

  def valid_response?(response)
    return false unless response.valid?

    response.validate_answers
    response.validate_html_tags
    true
  end

  def identifier_for(row)
    row['import_key'].presence || row['phone_number'].presence || row['email'].presence || '-'
  end

  def latest_response_round(consultation_id)
    @response_rounds ||= {}
    @response_rounds[consultation_id] ||= Consultation.find(consultation_id).response_rounds.order(:created_at).last
  end

  def find_user(hash)
    email = hash['email'].to_s.strip.presence
    phone_number = User.normalize_phone(hash['phone_number'])
    (User.find_by(email:) if email) || (User.find_by(phone_number:) if phone_number)
  end

  def build_answer(questions, key, value)
    return if NON_QUESTION_ID_HEADERS.include?(key) || value.blank?

    question = questions.find { |q| q.id == key.to_i }
    return unless question

    answer, other_option = extract_answer(question, value)
    answer_hash = { answer:, question_id: question.id.to_s }
    answer_hash.merge!(other_option_answer: value, is_other: 'true') if other_option && question.supports_other
    answer_hash
  end

  def extract_answer(question, value)
    case question.question_type
    when 'long_text'
      [value, nil]
    when 'checkbox'
      [value.split(',').map { |option| question.sub_questions.find { |sq| sq.question_text == option.strip }.id.to_s }, nil]
    else
      sub_question = question.sub_questions.find { |sq| sq.question_text == value }
      [sub_question&.id, (value unless sub_question)]
    end
  rescue StandardError
    [nil, value]
  end

  def duplicate?(response, seen_row_keys)
    key = dedup_key(response)
    return false if key.nil?
    return true if seen_row_keys.key?(key)

    scope = ConsultationResponse.where(response_round_id: response.response_round_id)
    if response[:phone_number].present?
      scope.exists?(phone_number: response[:phone_number])
    else
      scope.where('LOWER(email) = ?', response.email.downcase).exists?
    end
  end

  def dedup_key(response)
    identifier = response[:phone_number].presence || response.email&.downcase
    "#{response.response_round_id}:#{identifier}" if identifier
  end

  def build_consultation_response(row)
    ::ConsultationResponse.new do |response|
      SANITIZED_COLUMNS.each { |column| response.public_send("#{column}=", sanitize_column_value(row[column])) }
      response.phone_number = User.normalize_phone(row['phone_number'])&.delete('+')
      response.responded_at = parse_responded_at(row['responded_at'])
      response.source = :off_platform
      response.assign_attributes(get_question_id_with_answers_hash(row.to_h.with_indifferent_access))
    end
  end

  def parse_responded_at(value)
    sanitized = sanitize_column_value(value)
    return if sanitized.blank?

    Date.strptime(sanitized, '%d/%m/%Y')
  rescue Date::Error
    Date.parse(sanitized)
  end
end
