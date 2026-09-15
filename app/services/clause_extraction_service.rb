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
      prompt = PromptService.clause_extraction
      return failure_result("Extraction prompt not configured") unless prompt

      clauses_data = OpenAIService.new.call(
        attachment: consultation.consultation_pdf,
        prompt: prompt,
        schema_name: :clause_extraction
      )
      return failure_result("No clauses extracted") if clauses_data.blank?

      created_clauses = create_clauses(clauses_data)

      success_result(created_clauses)
    rescue StandardError => e
      Rails.logger.error("Clause extraction failed for Consultation #{consultation.id}: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      failure_result("Extraction failed: #{e.message}")
    end
  end

  private

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
      keywords: clause_data['keywords'].is_a?(Array) ? clause_data['keywords'].join(', ') : clause_data['keywords']
    )
  end

  def find_clause_type(type_name)
    return nil unless type_name.present?

    normalized_type = type_name.to_s.strip.titleize

    constant = Constant.find_by(constant_type: :clause_type, name: normalized_type)

    unless constant
      available_types = Constant.where(constant_type: :clause_type).pluck(:name).join(', ')
      Rails.logger.warn(
        "Clause type '#{type_name}' (normalized: '#{normalized_type}') not found. " \
        "Available types: #{available_types}. Skipping clause."
      )
    end

    constant
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
