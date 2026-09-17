require 'redcarpet'

class ConsultationPdfSummaryService
  attr_reader :consultation, :errors

  def initialize(consultation)
    @consultation = consultation
    @errors = []
  end

  def call
    return failure_result("Consultation not found") unless consultation
    return failure_result("Consultation PDF is required") unless consultation.consultation_pdf.attached?

    prompt = PromptService.draft_summarisation
    return failure_result("Summarisation prompt not configured") unless prompt

    summary_text = OpenAIService.new.call(
      attachment: consultation.consultation_pdf,
      prompt: prompt
    )
    return failure_result("No summary generated") if summary_text.blank?

    update_consultation_summary(summary_text)
    success_result(summary_text)
  rescue StandardError => e
    Rails.logger.error("ConsultationPdfSummaryService failed for Consultation #{consultation.id}: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    failure_result("Summarisation failed: #{e.message}")
  end

  private

  def update_consultation_summary(summary_text)
    html = markdown_to_html(summary_text)
    consultation.ai_summary = html
    consultation.save(validate: false)
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

  def success_result(summary)
    {
      success: true,
      summary: summary,
      message: "Successfully generated PDF summary"
    }
  end

  def failure_result(message)
    @errors << message
    {
      success: false,
      summary: nil,
      message: message,
      errors: @errors
    }
  end
end
