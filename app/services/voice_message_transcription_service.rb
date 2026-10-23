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
    prompt = PromptService.voice_transcription(@context)
    result = OpenAIService.new.transcribe_audio(attachment:, prompt:, language: language_code)
    return failure('Transcription returned empty content') if result&.dig('transcription').blank?

    success(result)
  rescue StandardError => e
    failure("Transcription failed: #{e.message}")
  end

  private

  def language_code
    LANGUAGE_CODES[@context[:response_language].to_s.downcase]
  end

  def success(result)
    {
      success: true,
      transcription: result['transcription'],
      detected_language: result['detected_language'],
      is_proper_transcription: result['is_proper_transcription'],
      errors: []
    }
  end

  def failure(message)
    @errors << message
    { success: false, transcription: nil, detected_language: nil,
      is_proper_transcription: false, errors: @errors }
  end
end
