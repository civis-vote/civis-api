class ConsultationSummaryService
  SUMMARY_MODEL = 'gpt-5.6-luna'.freeze
  PROMPT_FILE = Rails.root.join('config/prompts/consultation_ai_summary.prompt').freeze

  LANGUAGES = {
    'English' => :english_response_summary,
    'Hindi' => :hindi_response_summary,
    'Marathi' => :marathi_response_summary,
    'Odia' => :odia_response_summary,
    'Kannada' => :kannada_response_summary
  }.freeze

  attr_reader :consultation, :errors

  def initialize(consultation)
    @consultation = consultation
    @errors = []
  end

  def call
    return failure_result("Consultation not found") unless consultation
    return failure_result("Consultation has no acceptable responses") unless consultation.responses.acceptable.exists?

    responses_data = collect_question_responses
    return failure_result("No question responses found to summarize") if responses_data.blank?

    summaries = {}

    LANGUAGES.each do |language, attribute|
      prompt = build_prompt(responses_data, language)
      result = generate_summary(prompt)
      next unless result.present?

      consultation.send("#{attribute}=", result)
      summaries[language] = result
    end

    return failure_result("AI summary generation returned empty content for all languages") if summaries.blank?

    consultation.save(validate: false)
    success_result(summaries)
  rescue StandardError => e
    Airbrake.notify(e)
    failure_result("Summary generation failed: #{e.message}")
  end

  private

  def collect_question_responses
    responses = consultation.responses.acceptable.includes(:response_round, :user)
    formatted = []

    responses.each_with_index do |response, index|
      response_entry = build_response_entry(response, index + 1)
      formatted << response_entry if response_entry.present?
    end

    formatted
  end

  def build_response_entry(response, index)
    if response.response_round&.questions&.present?
      build_question_answer_entry(response, index)
    else
      build_generic_response_entry(response, index)
    end
  end

  def build_question_answer_entry(response, index)
    answers_hash = response.user_answers
    return nil if answers_hash.blank? || answers_hash.values.all?(&:blank?)

    qa_pairs = answers_hash.map do |question_text, answer_text|
      next if answer_text.blank?

      "    Q: #{question_text}\n    A: #{answer_text}"
    end.compact

    return nil if qa_pairs.blank?

    <<~ENTRY
      Response ##{index}:
      #{qa_pairs.join("\n")}
    ENTRY
  end

  def build_generic_response_entry(response, index)
    parts = []
    text = response.response_text&.to_plain_text
    parts << text if text.present?
    parts.concat(voice_transcriptions(response))
    return nil if parts.blank?

    <<~ENTRY
      Response ##{index}:
      #{parts.join("\n")}
    ENTRY
  end

  def voice_transcriptions(response)
    Array(response.voice_responses).filter_map do |entry|
      transcription = entry['transcription'] || entry[:transcription]
      "Voice message transcription: #{transcription}" if transcription.present?
    end
  end

  def build_prompt(responses_data, language)
    File.read(PROMPT_FILE).strip
        .gsub('{{CONSULTATION_TITLE}}', consultation.title.to_s)
        .gsub('{{CONSULTATION_TYPE}}', consultation.review_type.to_s)
        .gsub('{{DEPARTMENT_NAME}}', consultation.department_name.to_s)
        .gsub('{{RESPONSES_DATA}}', responses_data.join("\n\n"))
        .gsub('{{OUTPUT_LANGUAGE}}', language)
  end

  def generate_summary(prompt)
    client = OpenAI::Client.new(
      access_token: Rails.application.credentials.openai[:api_key],
      request_timeout: OpenAIService::REQUEST_TIMEOUT
    )

    response = client.responses.create(
      parameters: {
        model: SUMMARY_MODEL,
        input: [{ role: 'user', content: [{ type: 'input_text', text: prompt }] }],
        text: { format: StructuredOutputService.consultation_summary }
      }
    )

    response_text = response['output']
                    .flat_map { |o| o['content'] || [] }
                    .map { |c| c['text'] }
                    .compact
                    .join("\n")
                    .strip

    format_summary(JSON.parse(response_text))
  rescue StandardError => e
    Airbrake.notify(e)
    nil
  end

  def format_summary(result)
    sections = %w[frequently_raised diverging_views also_raised].map do |key|
      section = result[key]
      "#{section['label']}: #{Array(section['points']).join(', ')}"
    end

    [result['opening_paragraph'], *sections].join("\n")
  end

  def success_result(summaries)
    {
      success: true,
      summaries: summaries,
      message: "AI summaries generated successfully for #{summaries.keys.join(', ')}"
    }
  end

  def failure_result(message)
    @errors << message
    {
      success: false,
      summaries: nil,
      message: message,
      errors: @errors
    }
  end
end
