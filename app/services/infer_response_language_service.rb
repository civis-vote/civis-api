class InferResponseLanguageService
  attr_reader :consultation_response, :errors

  def initialize(consultation_response)
    @consultation_response = consultation_response
    @errors = []
  end

  def call
    long_text_content = extract_long_text_answers
    inferred_language = long_text_content.present? ? infer_language(long_text_content) : 'English'
    consultation_response.update(response_language: inferred_language)
    { success: true, response_language: inferred_language, errors: [] }
  rescue StandardError => e
    Rails.logger.error("InferResponseLanguageService failed for ConsultationResponse ID #{consultation_response.id}: #{e.message}")
    consultation_response.update(response_language: 'English')
    @errors << e.message
    { success: false, response_language: 'English', errors: @errors }
  end

  private

  def extract_long_text_answers
    return "" unless consultation_response.response_round.present?
    return "" unless consultation_response.response_round.questions.present?
    return "" unless consultation_response.answers.present?

    long_text_question_ids = consultation_response.response_round.questions
                                                  .where(question_type: :long_text)
                                                  .pluck(:id)

    return "" if long_text_question_ids.empty?

    consultation_response.answers
                         .select { |answer| long_text_question_ids.include?(answer['question_id'].to_i) }
                         .map { |answer| answer['answer'] }
                         .compact
                         .join(' ')
  end

  def infer_language(text)
    response = openai_client.chat(
      parameters: {
        model: OpenAIService::DEFAULT_MODEL,
        messages: [{ role: 'user', content: build_prompt(text) }]
      }
    )

    normalize_language(response.dig('choices', 0, 'message', 'content'))
  end

  def openai_client
    @openai_client ||= OpenAI::Client.new(access_token: Rails.application.credentials.dig(:openai, :api_key))
  end

  def build_prompt(text)
    PromptService.from_file(
      'response_language_inference.prompt',
      languages: ConsultationResponse.response_languages.values.join(', '),
      text: CGI.escapeHTML(text)
    )
  end

  def normalize_language(language)
    return 'English' if language.blank?

    language.strip.capitalize
  end
end
