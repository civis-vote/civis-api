class VoiceMessageTranscriptionService
  LANGUAGE_CODES = {
    'english' => 'en',
    'hindi' => 'hi',
    'marathi' => 'mr',
    'odia' => 'or',
    'kannada' => 'kn'
  }.freeze

  attr_reader :attachment, :errors

  def initialize(attachment, context = {})
    @attachment = attachment
    @context = context
    @errors = []
  end

  def call
    prompt = PromptService.voice_transcription(
      consultation_topic: @context[:consultation_topic],
      response_language: @context[:response_language],
      question_text: @context[:question_text]
    )
    return failure('Transcription prompt not configured') unless prompt

    result = OpenAIService.new.transcribe_audio(
      attachment: attachment,
      prompt: prompt,
      language: language_code
    )
    return failure('Transcription returned empty content') if result.blank? || result['transcription'].blank?

    {
      success: true,
      transcription: result['transcription'],
      detected_language: result['detected_language'],
      confidence: result['confidence'],
      is_proper_transcription: result['is_proper_transcription'],
      errors: []
    }
  rescue StandardError => e
    failure("Transcription failed: #{e.message}")
  end

  private

  def language_code
    LANGUAGE_CODES[@context[:response_language].to_s.downcase]
  end

  def failure(message)
    @errors << message
    { success: false, transcription: nil, detected_language: nil, confidence: nil,
      is_proper_transcription: false, errors: @errors }
  end
end
