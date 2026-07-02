require 'tempfile'
require 'openai'

class ClauseExtractionService

  attr_reader :consultation, :errors

  def initialize(consultation)
    @consultation = consultation
    @errors = []
  end

  def call
    return failure_result("Consultation not found") unless consultation
    return failure_result("Consultation PDF is required") unless consultation.consultation_pdf.attached?

    begin
      # Get PDF path from attached file
      pdf_path = get_pdf_path
      return failure_result("Failed to get PDF path") unless pdf_path

      # Get prompt from platform settings
      prompt = get_extraction_prompt
      return failure_result("Extraction prompt not configured") unless prompt

      # Extract clauses using OpenAI
      clauses_data = extract_clauses_from_pdf(pdf_path, prompt)
      return failure_result("No clauses extracted") if clauses_data.blank?

      # Create clause records
      created_clauses = create_clauses(clauses_data)

      success_result(created_clauses)
    rescue StandardError => e
      Rails.logger.error("Clause extraction failed for Consultation #{consultation.id}: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      failure_result("Extraction failed: #{e.message}")
    ensure
      cleanup_temp_files
    end
  end

  private

  def get_pdf_path
    @temp_files ||= []

    begin
      # Download the attached PDF to a temp file
      temp_file = Tempfile.new(['consultation_pdf', '.pdf'])
      temp_file.binmode
      @temp_files << temp_file

      consultation.consultation_pdf.download do |chunk|
        temp_file.write(chunk)
      end

      temp_file.close
      temp_file.path
    rescue StandardError => e
      Rails.logger.error("Failed to get PDF from consultation #{consultation.id}: #{e.message}")
      nil
    end
  end

  def get_extraction_prompt
    CmPlatformSetting.find_by(slug: 'agent-clause-table-prompt')&.value
  end

  def extract_clauses_from_pdf(pdf_path, prompt)
    client = OpenAI::Client.new(
      access_token: Rails.application.credentials.openai[:api_key],
      request_timeout: 600
    )

    pdf_file = File.open(pdf_path, 'rb')

    begin
      file = client.files.upload(
        parameters: {
          file: pdf_file,
          purpose: "user_data"
        }
      )
    rescue StandardError => e
      pdf_file&.close
      raise e
    end

    begin
      # Send PDF to model with prompt
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
        .gsub(/\A```(?:json)?\s*|\s*```\z/m, '')
        .strip
      JSON.parse(response_text)
    rescue JSON::ParserError => e
      Rails.logger.error("Failed to parse OpenAI response as JSON: #{e.message}")
      Rails.logger.error("Response text: #{response_text[0..500]}")
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

  def create_clauses(clauses_data)
    clauses_array = if clauses_data.is_a?(Array)
      clauses_data
    elsif clauses_data.is_a?(Hash) && clauses_data['clauses'].is_a?(Array)
      clauses_data['clauses']
    else
      return []
    end

    created_clauses = []

    ActiveRecord::Base.transaction do
      clauses_array.each_with_index do |clause_data, index|
        clause = build_clause(clause_data, index + 1)
        
        if clause.valid?
          clause.save!
          created_clauses << clause
        else
          Rails.logger.warn("Invalid clause data at index #{index}: #{clause.errors.full_messages.join(', ')}")
        end
      end
    end

    created_clauses
  end

  def build_clause(clause_data, index)
    Clause.new(
      consultation: consultation,
      clause_id: clause_data['clause_id'] || "CL-#{index.to_s.rjust(4, '0')}",
      clause_title: clause_data['clause_title'],
      what_is_being_proposed: clause_data['what_is_proposed'],
      clause_type: find_clause_type(clause_data['clause_type']),
      stakeholder_impact: clause_data['stakeholder_impact'],
      keywords: clause_data['keywords']&.is_a?(Array) ? clause_data['keywords'].join(', ') : clause_data['keywords']
    )
  end

  def find_clause_type(type_name)
    return nil unless type_name.present?

    normalized_type = type_name.to_s.strip.titleize

    constant = Constant.find_by(constant_type: :clause_type, name: normalized_type)

    unless constant
      available_types = Constant.where(constant_type: :clause_type).pluck(:name).join(', ')
      Rails.logger.warn("Clause type '#{type_name}' (normalized: '#{normalized_type}') not found. Available types: #{available_types}. Skipping clause.")
    end

    constant
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

  def success_result(clauses)
    {
      success: true,
      clauses: clauses,
      message: "Successfully extracted #{clauses.size} clauses"
    }
  end

  def failure_result(message)
    {
      success: false,
      clauses: [],
      message: message,
      errors: [message]
    }
  end
end
