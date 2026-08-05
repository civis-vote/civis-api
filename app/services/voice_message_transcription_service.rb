require 'tempfile'

class VoiceMessageTranscriptionService
  TRANSCRIPTION_MODEL = 'google/gemini-3.5-flash-lite'.freeze
  PROMPT_FILE = Rails.root.join('config/prompts/voice_message_transcription.prompt').freeze

  attr_reader :attachment, :errors

  def initialize(attachment, context = {})
    @attachment = attachment
    @context = context
    @errors = []
    @temp_files = []
  end

  def call
    audio_path = download_audio_to_tempfile
    return failure('Failed to download voice message audio') unless audio_path

    result = transcribe_audio(audio_path)
    return failure('Transcription returned empty content') if result.blank?

    { success: true, transcription: result['transcription'].to_s.strip,
      detected_language: result['detected_language'], confidence: result['confidence'], errors: [] }
  rescue StandardError => e
    failure("Transcription failed: #{e.message}")
  ensure
    cleanup_temp_files
  end

  private

  def download_audio_to_tempfile
    extension = File.extname(attachment.filename.to_s).presence || '.mp3'
    temp_file = Tempfile.new(['voice_message', extension])
    temp_file.binmode
    @temp_files << temp_file

    attachment.blob.download { |chunk| temp_file.write(chunk) }
    temp_file.close
    temp_file.path
  rescue StandardError
    nil
  end

  def transcribe_audio(audio_path)
    chat = RubyLLM.chat(
      model: TRANSCRIPTION_MODEL,
      provider: :openrouter,
      assume_model_exists: true
    )
    chat.with_schema(VoiceMessageTranscriptionSchema)
        .ask(transcription_prompt, with: audio_path)&.content
  end

  def transcription_prompt
    File.read(PROMPT_FILE).strip
        .gsub('{{CONSULTATION_TOPIC}}', @context[:consultation_topic].to_s)
        .gsub('{{RESPONSE_LANGUAGE}}', @context[:response_language].to_s)
        .gsub('{{QUESTION_TEXT}}', @context[:question_text].to_s)
  end

  def cleanup_temp_files
    return unless @temp_files

    @temp_files.each do |file|
      file.close if file.respond_to?(:close)
      FileUtils.rm_f(file.path)
    rescue StandardError
      next
    end
    @temp_files = nil
  end

  def failure(message)
    @errors << message
    { success: false, transcription: nil, detected_language: nil, confidence: nil, errors: @errors }
  end
end
