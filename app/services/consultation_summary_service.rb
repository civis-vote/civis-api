require 'tempfile'
require 'openai'
require 'redcarpet'

class ConsultationSummaryService
  attr_reader :consultation, :errors

  def initialize(consultation)
    @consultation = consultation
    @errors = []
  end

  def call
    return failure_result("Consultation not found") unless consultation
    return failure_result("Consultation PDF is required") unless consultation.pdf.attached?

    begin
      # Extract PDF from Active Storage
      pdf_path = extract_pdf_from_storage
      return failure_result("Failed to extract PDF from storage") unless pdf_path

      # Get prompt from platform settings
      prompt = get_summarisation_prompt
      return failure_result("Summarisation prompt not configured") unless prompt

      # Summarise PDF using OpenAI
      summary_text = summarise_pdf(pdf_path, prompt)
      return failure_result("No summary generated") if summary_text.blank?

      # Update consultation with summary
      update_consultation_summary(summary_text)

      success_result(summary_text)
    rescue StandardError => e
      Rails.logger.error("Consultation summarisation failed for Consultation #{consultation.id}: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      failure_result("Summarisation failed: #{e.message}")
    ensure
      cleanup_temp_files
    end
  end

  private

  def extract_pdf_from_storage
    @temp_files ||= []

    begin
      return nil unless consultation.pdf.attached?

      pdf_blob = consultation.pdf.blob
      temp_file = Tempfile.new(['consultation_pdf', '.pdf'])
      temp_file.binmode
      @temp_files << temp_file

      temp_file.write(pdf_blob.download)
      temp_file.close
      temp_file.path
    rescue StandardError => e
      Rails.logger.error("Failed to extract PDF from Active Storage for Consultation #{consultation.id}: #{e.message}")
      nil
    end
  end

  def get_summarisation_prompt
    CmPlatformSetting.find_by(slug: 'agent-draft-summariser-prompt')&.value
  end

  def summarise_pdf(pdf_path, prompt)
    client = OpenAI::Client.new(
      access_token: Rails.application.credentials.openai[:api_key],
      request_timeout: 600
    )

    pdf_file = File.open(pdf_path, 'rb')
    file = client.files.upload(
      parameters: {
        file: pdf_file,
        purpose: "user_data"
      }
    )

    begin
      response = client.responses.create(
        parameters: {
          model: "gpt-4.1",
          temperature: 0,
          input: [
            {
              role: "user",
              content: [
                {
                  type: "input_file",
                  file_id: file["id"]
                },
                {
                  type: "input_text",
                  text: prompt
                }
              ]
            }
          ]
        }
      )

      response_text = response["output"]
        .flat_map { |o| o["content"] || [] }
        .map { |c| c["text"] }
        .compact
        .join("\n")
        .strip

      response_text
    rescue StandardError => e
      Rails.logger.error("Failed to get response from OpenAI: #{e.message}")
      nil
    ensure
      pdf_file&.close
      begin
        client.files.delete(id: file["id"])
      rescue StandardError => e
        Rails.logger.warn("Failed to delete OpenAI file #{file["id"]}: #{e.message}")
      end
    end
  end

  def update_consultation_summary(summary_text)
    html = markdown_to_html(summary_text)
    consultation.ai_summary = html
    consultation.save
  end

  def markdown_to_html(text)
    renderer = Redcarpet::Render::HTML.new(
      hard_wrap: true,
      no_links: false,
      safe_links_only: true
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

  def cleanup_temp_files
    return unless @temp_files

    @temp_files.each do |file|
      begin
        file.close if file.respond_to?(:close)
        File.unlink(file.path) if File.exist?(file.path)
      rescue StandardError => e
        Rails.logger.warn("Failed to cleanup temp file #{file&.path}: #{e.message}")
      end
    end
    @temp_files = nil
  end

  def success_result(summary)
    {
      success: true,
      summary: summary,
      message: "Successfully generated summary"
    }
  end

  def failure_result(message)
    {
      success: false,
      summary: nil,
      message: message,
      errors: [message]
    }
  end
end
