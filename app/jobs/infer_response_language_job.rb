class InferResponseLanguageJob < ApplicationJob
  queue_as :default

  def perform(consultation_response)
    long_text_content = extract_long_text_answers(consultation_response)

    if long_text_content.blank?
      consultation_response.update(inferred_language: "English")
      return
    end

    inferred_language = infer_language_from_openai(long_text_content)

    consultation_response.update(inferred_language: inferred_language)
  rescue StandardError => e
    Rails.logger.error("InferResponseLanguageJob failed for ConsultationResponse ID #{consultation_response.id}: #{e.message}")
    consultation_response.update(inferred_language: "English")
  end

  private

  def extract_long_text_answers(consultation_response)
    return "" unless consultation_response.response_round.present?
    return "" unless consultation_response.response_round.questions.present?
    return "" unless consultation_response.answers.present?

    long_text_question_ids = consultation_response.response_round.questions
                                                  .where(question_type: :long_text)
                                                  .pluck(:id)

    return "" if long_text_question_ids.empty?

    long_text_answers = consultation_response.answers.select do |answer|
      long_text_question_ids.include?(answer['question_id'].to_i)
    end.map { |answer| answer['answer'] }.compact

    long_text_answers.join(' ')
  end

  def infer_language_from_openai(text)
    api_key = Rails.application.credentials.dig(:openai, :api_key)
    client = OpenAI::Client.new(access_token: api_key)

    prompt = build_prompt(text)

    response = client.chat(
      parameters: {
        model: "gpt-5-nano",
        messages: [{ role: "user", content: prompt }],
      }
    )

    language = response.dig("choices", 0, "message", "content")&.strip

    normalize_language(language)
  rescue StandardError => e
    Rails.logger.error("OpenAI API call failed: #{e.message}")
    "English"
  end

  def build_prompt(text)
    <<~PROMPT
      You are a language detector. Analyze the following text and return ONLY the language name in which it is written.

      Rules:
      1) Return exactly one word - the language name.
      2) If multiple languages are present, return the language used for the longest content.
      3) Prefer non-English languages over English if both are present.
      4) Return language name in proper case (e.g., 'Hindi', 'English', 'Spanish').

      Text to analyze: #{text}
    PROMPT
  end

  def normalize_language(language)
    return "English" if language.blank?

    language.strip.capitalize
  end
end
