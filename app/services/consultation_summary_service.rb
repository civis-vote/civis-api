require 'cgi'
require 'redcarpet'

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
    if response_summaries_present?
      return { success: true, summaries: {}, message: "Response summaries already generated", errors: [] }
    end

    responses_data = collect_question_responses
    return failure_result("No question responses found to summarize") if responses_data.blank?

    summaries = {}

    LANGUAGES.each do |language, attribute|
      next if consultation.send(attribute).present?

      prompt = build_prompt(responses_data, language)
      result = generate_summary(prompt)
      next unless result.present?

      html = markdown_to_html(result)
      consultation.send("#{attribute}=", html)
      summaries[language] = html
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
    by_question = Hash.new { |hash, key| hash[key] = [] }
    free_form = []

    consultation.responses.acceptable.includes(:user, response_round: :questions).each do |response|
      if response.response_round&.questions&.present?
        response.user_answers.each do |question_text, answer_text|
          by_question[question_text] << escape(answer_text.strip) if answer_text.present?
        end
      else
        entry = free_form_entry(response)
        free_form << entry if entry.present?
      end
    end

    format_question_blocks(by_question) + free_form
  end

  def format_question_blocks(by_question)
    by_question.map do |question_text, answers|
      answer_lines = answers.map { |answer| "  <answer>#{answer}</answer>" }.join("\n")
      <<~BLOCK
        <question>
          <text>#{question_text}</text>
        #{answer_lines}
        </question>
      BLOCK
    end
  end

  def free_form_entry(response)
    parts = []
    text = response.response_text&.to_plain_text
    parts << escape(text) if text.present?
    parts.concat(voice_transcriptions(response).map { |line| escape(line) })
    return nil if parts.blank?

    <<~ENTRY
      <free_response>
      #{parts.join("\n")}
      </free_response>
    ENTRY
  end

  def voice_transcriptions(response)
    Array(response.voice_responses).filter_map do |entry|
      transcription = entry['transcription'] || entry[:transcription]
      "Voice message transcription: #{transcription}" if transcription.present?
    end
  end

  def escape(text)
    CGI.escapeHTML(text)
  end

  def build_prompt(responses_data, language)
    File.read(PROMPT_FILE).strip
        .gsub('{{CONSULTATION_TITLE}}') { consultation.title.to_s }
        .gsub('{{CONSULTATION_TYPE}}') { consultation.review_type.to_s }
        .gsub('{{DEPARTMENT_NAME}}') { consultation.department_name.to_s }
        .gsub('{{RESPONSES_DATA}}') { responses_data.join("\n\n") }
        .gsub('{{OUTPUT_LANGUAGE}}') { language }
  end

  def openai_client
    @openai_client ||= OpenAI::Client.new(
      access_token: Rails.application.credentials.openai[:api_key],
      request_timeout: OpenAIService::REQUEST_TIMEOUT
    )
  end

  def generate_summary(prompt)
    response = openai_client.responses.create(
      parameters: {
        model: SUMMARY_MODEL,
        input: [{ role: 'user', content: [{ type: 'input_text', text: prompt }] }]
      }
    )

    response['output']
      .flat_map { |o| o['content'] || [] }
      .map { |c| c['text'] }
      .compact
      .join("\n")
      .strip
  rescue StandardError => e
    Airbrake.notify(e)
    nil
  end

  def markdown_to_html(text)
    renderer = Redcarpet::Render::HTML.new(
      hard_wrap: true,
      no_links: false,
      safe_links_only: true,
      escape_html: true,
      filter_html: true
    )
    markdown = Redcarpet::Markdown.new(
      renderer,
      autolink: true,
      tables: true,
      fenced_code_blocks: true,
      strikethrough: true,
      superscript: true,
      underline: true,
      lax_spacing: true,
      space_after_headers: false
    )
    markdown.render(text)
  end

  def response_summaries_present?
    LANGUAGES.values.all? { |attribute| consultation.send(attribute).present? }
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
