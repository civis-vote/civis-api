require 'tempfile'
require 'openai'

class OpenAIService
  DEFAULT_MODEL = 'gpt-5.6-luna'.freeze
  REQUEST_TIMEOUT = 600

  class Error < StandardError; end

  attr_reader :temp_files

  def initialize
    @temp_files = []
  end

  def call(attachment:, prompt:, schema_name: nil, model: DEFAULT_MODEL, temperature: nil)
    pdf_path = download_attachment(attachment)
    return nil unless pdf_path

    begin
      send_pdf_request(pdf_path, prompt, schema_name, model, temperature)
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
    temp_file = Tempfile.new(['consultation_pdf', '.pdf'])
    temp_file.binmode
    @temp_files << temp_file

    attachment.download { |chunk| temp_file.write(chunk) }
    temp_file.close
    temp_file.path
  rescue StandardError => e
    Rails.logger.error("Failed to download attachment: #{e.message}")
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
    Rails.logger.error("Failed to parse OpenAI response as JSON: #{e.message}")
    Rails.logger.error("Response text: #{response_text[0..500]}")
    nil
  end

  def delete_uploaded_file(uploaded_file)
    return unless uploaded_file

    client.files.delete(id: uploaded_file['id'])
  rescue StandardError => e
    Rails.logger.warn("Failed to delete OpenAI file #{uploaded_file['id']}: #{e.message}")
  end

  def cleanup_temp_files
    @temp_files.each do |file|
      file.close if file.respond_to?(:close)
      FileUtils.rm_f(file.path)
    rescue StandardError => e
      Rails.logger.warn("Failed to cleanup temp file #{file&.path}: #{e.message}")
    end
    @temp_files = []
  end
end
