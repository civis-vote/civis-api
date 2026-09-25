require 'tempfile'
require 'openai'

class OpenAIService
  DEFAULT_MODEL = 'gpt-5.6-luna'.freeze
  AUDIO_MODEL = 'whisper-1'.freeze
  REQUEST_TIMEOUT = 600

  class Error < StandardError; end

  attr_reader :temp_files

  def initialize
    @temp_files = []
  end

  def call(attachment:, prompt:, schema_name: nil, model: DEFAULT_MODEL, temperature: nil)
    file_path = download_attachment(attachment)
    return nil unless file_path

    begin
      send_pdf_request(file_path, prompt, schema_name, model, temperature)
    ensure
      cleanup_temp_files
    end
  end

  def transcribe_audio(attachment:, prompt: nil, model: AUDIO_MODEL, language: nil)
    audio_path = download_attachment(attachment)
    return nil unless audio_path

    begin
      raw_text = send_audio_request(audio_path, model, language)
      return nil unless raw_text

      refine_transcription(raw_text, prompt)
    ensure
      cleanup_temp_files
    end
  end

  private

  def client
    @client ||= OpenAI::Client.new(
      access_token: Rails.application.credentials.openai[:api_key],
      request_timeout: REQUEST_TIMEOUT
    )
  end

  def download_attachment(attachment)
    extension = File.extname(attachment.filename.to_s).presence || '.bin'
    temp_file = Tempfile.new(['attachment', extension])
    temp_file.binmode
    @temp_files << temp_file

    attachment.download { |chunk| temp_file.write(chunk) }
    temp_file.close
    temp_file.path
  rescue StandardError => e
    Airbrake.notify(e)
    nil
  end

  def send_pdf_request(pdf_path, prompt, schema_name, model, temperature)
    pdf_file = File.open(pdf_path, 'rb')

    begin
      uploaded_file = client.files.upload(
        parameters: { file: pdf_file, purpose: 'user_data' }
      )
    rescue StandardError => e
      pdf_file&.close
      raise e
    end

    begin
      parameters = build_parameters(uploaded_file, prompt, schema_name, model, temperature)
      response = client.responses.create(parameters: parameters)
      parse_response(response, schema_name)
    ensure
      pdf_file&.close
      delete_uploaded_file(uploaded_file)
    end
  end

  def build_parameters(uploaded_file, prompt, schema_name, model, temperature)
    params = {
      model: model,
      input: [
        {
          role: 'user',
          content: [
            { type: 'input_file', file_id: uploaded_file['id'] },
            { type: 'input_text', text: prompt }
          ]
        }
      ]
    }

    params[:temperature] = temperature if temperature.present?
    params[:text] = { format: StructuredOutputService.public_send(schema_name) } if schema_name.present?
    params
  end

  def parse_response(response, schema_name)
    response_text = response['output']
                    .flat_map { |o| o['content'] || [] }
                    .map { |c| c['text'] }
                    .compact
                    .join("\n")
                    .strip

    return response_text if schema_name.blank?

    response_text = response_text.gsub(/\A```(?:json)?\s*|\s*```\z/m, '').strip
    JSON.parse(response_text)
  rescue JSON::ParserError => e
    Airbrake.notify(e)
    nil
  end

  def delete_uploaded_file(uploaded_file)
    return unless uploaded_file

    client.files.delete(id: uploaded_file['id'])
  rescue StandardError => e
    Airbrake.notify(e)
  end

  def send_audio_request(audio_path, model, language)
    audio_file = File.open(audio_path, 'rb')

    parameters = { model: model, file: audio_file, response_format: 'verbose_json' }
    parameters[:language] = language if language.present?

    response = client.audio.transcribe(parameters: parameters)
    response['text'].to_s.strip
  rescue StandardError => e
    Rails.logger.error("Audio transcription failed: #{e.message}")
    nil
  ensure
    audio_file&.close
  end

  def refine_transcription(raw_text, prompt)
    refinement_prompt = build_refinement_prompt(raw_text, prompt)

    parameters = {
      model: DEFAULT_MODEL,
      input: [
        {
          role: 'user',
          content: [{ type: 'input_text', text: refinement_prompt }]
        }
      ],
      text: { format: StructuredOutputService.voice_transcription }
    }

    response = client.responses.create(parameters: parameters)
    result = parse_response(response, :voice_transcription)
    return nil unless result

    result
  rescue StandardError => e
    Rails.logger.error("Transcription refinement failed: #{e.message}")
    {
      'transcription' => raw_text,
      'detected_language' => nil,
      'is_proper_transcription' => true,
      'confidence' => nil
    }
  end

  def build_refinement_prompt(raw_text, original_prompt)
    <<~PROMPT
      You are a transcription refinement assistant. Below is a raw transcription of a voice message from a citizen consultation response. Your task is to:

      1. Identify the language of the transcription (e.g., English, Hindi, Marathi, Odia, Kannada or a mix).
      2. Clean up the transcription if it contains errors, garbled text, or improper formatting — but preserve the speaker's exact meaning and wording. Do not translate.
      3. Remove obvious duplications introduced by the speech-to-text model (e.g., if the same phrase is repeated consecutively and appears to be a model artifact rather than the speaker actually repeating themselves, keep only one instance).
      4. If the transcription is entirely inaudible, unintelligible, or empty, set is_proper_transcription to false and return the raw text as-is.
      5. Provide a confidence score (0.0 to 1.0) based on how clear and complete the transcription appears.

      Original transcription context and instructions:
      #{original_prompt}

      Raw transcription to refine:
      ---
      #{raw_text}
      ---
    PROMPT
  end

  def cleanup_temp_files
    @temp_files.each do |file|
      file.close if file.respond_to?(:close)
      FileUtils.rm_f(file.path)
    rescue StandardError => e
      Airbrake.notify(e)
    end
    @temp_files = []
  end
end
