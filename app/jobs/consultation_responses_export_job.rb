class ConsultationResponsesExportJob < ApplicationJob
  require 'axlsx'

  queue_as :default

  def perform(file_export:)
    consultation = ::Consultation.find(file_export.associated_model_id)
    generate_and_attach_responses(consultation, file_export)
  end

  private

  def generate_and_attach_responses(consultation, file_export)
    Dir.mktmpdir("/tmp/file_export_#{file_export.id}") do |temp_dir|
      filename = "consultation_#{consultation.id}_responses_#{Time.now.to_i}.xlsx"
      excel_file_path = File.join(temp_dir, filename)

      begin
        generate_excel_file(consultation, excel_file_path)

        file_export.export_file.attach(
          io: File.open(excel_file_path),
          filename: filename,
          content_type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        )

        file_export.success!
      rescue StandardError => e
        Rails.logger.error("Consultation responses export failed for Consultation: #{consultation.id}, Error: #{e.message}")
        Rails.logger.error(e.backtrace.join("\n"))
        raise e
      end
    end
  end

  def generate_excel_file(consultation, excel_file_path)
    xlsx = Axlsx::Package.new

    consultation.response_rounds.order(:round_number).each do |response_round|
      add_response_round_worksheet(xlsx, consultation, response_round)
    end

    xlsx.use_shared_strings = true
    xlsx.serialize(excel_file_path)
  end

  def add_response_round_worksheet(xlsx, consultation, response_round)
    wrap_style = xlsx.workbook.styles.add_style alignment: { wrap_text: true }

    xlsx.workbook.add_worksheet(name: "Responses - Round #{response_round.round_number}") do |sheet|
      # Build headers
      static_headers = build_static_headers
      question_headers = response_round.questions.order(:created_at).pluck(:question_text)
      all_headers = static_headers + question_headers

      sheet.add_row all_headers, b: true

      # Get responses for this round and add data rows
      responses = consultation.responses
                             .where(response_round_id: response_round.id)
                             .includes(:user, :response_round, response_round: :questions)

      response_data = collect_response_data(responses, response_round)

      response_data.each do |data_struct|
        row_data = build_row_data(data_struct, question_headers)
        sheet.add_row row_data, style: wrap_style
      end

      # Set column widths
      column_widths = Array.new(all_headers.length, 22)
      sheet.column_widths(*column_widths)
    end
  end

  def build_static_headers
    [
      'Consultation Title',
      'Category',
      'Consultation Response Text',
      'Submitted By',
      'Responder Email',
      'City',
      'Phone Number',
      'Satisfaction Rating',
      'Visibility',
      'Submitted At',
      'Is Verified',
      'Source',
      'Organisation/Department',
      'Designation',
      'Language',
      'Status'
    ]
  end

  def collect_response_data(responses, response_round)
    responses.map do |response|
      OpenStruct.new(
        consultation_title: response.consultation_title,
        theme: response.theme,
        user_response: response.user_response,
        submitted_by: response.submitted_by,
        responder_email: response.responder_email,
        city: response.city,
        phone_number: response.phone_number,
        satisfaction_rating: response.satisfaction_rating,
        visibility: response.visibility,
        submitted_at: response.submitted_at,
        is_verified: response.is_verified,
        source: response.source,
        organisation: response.organisation,
        designation: response.designation,
        language: response.response_language,
        response_status: response.response_status,
        user_answers: response.user_answers
      )
    end
  end

  def build_row_data(data_struct, question_headers)
    static_data = [
      data_struct.consultation_title,
      data_struct.theme,
      data_struct.user_response,
      data_struct.submitted_by,
      data_struct.responder_email,
      data_struct.city,
      data_struct.phone_number,
      data_struct.satisfaction_rating,
      data_struct.visibility,
      data_struct.submitted_at,
      data_struct.is_verified,
      data_struct.source,
      data_struct.organisation,
      data_struct.designation,
      data_struct.language,
      data_struct.response_status
    ]

    # Add dynamic question answers
    question_answers = question_headers.map do |question_text|
      data_struct.user_answers[question_text] || ''
    end

    static_data + question_answers
  end
end
