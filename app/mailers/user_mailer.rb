class UserMailer < ApplicationMailer
  require 'axlsx'

  def notify_new_consultation_policy_review_email(user, consultation)
    deliver_with_template_and_log(from: @@from_email,
                                  to: user.email,
                                  reply_to: 'support@civis.vote',
                                  template_alias: 'notify-new-consultation-policy-review',
                                  subject: "Consultation policy review: #{consultation.title}",
                                  module_name: 'Consultation',
                                  record: consultation,
                                  template_model: {
                                    first_name: user.first_name,
                                    consultation_name: consultation.title,
                                    ministry_name: consultation.department.name,
                                    feedback_url: consultation.feedback_url,
                                    unsubscribe_url: user.unsubscribe_url,
                                    product_url: Rails.application.config.client_url[:host]
                                  })
  end

  def notify_new_consultation_email_to_admin(user, consultation)
    deliver_with_template_and_log(from: @@from_email,
                                  to: user.email,
                                  reply_to: 'support@civis.vote',
                                  template_alias: 'notify-new-consultation-to-admin',
                                  subject: "New consultation: #{consultation.title}",
                                  module_name: 'Consultation',
                                  record: consultation,
                                  template_model: {
                                    consultation_name: consultation.title,
                                    deadline: consultation.response_deadline.strftime('%e-%m-%Y %I:%M %p'),
                                    review_url: consultation.review_url,
                                    product_url: Rails.application.config.client_url[:host]
                                  })
  end

  def notify_profane_response_email_to_admin(user, consultation_response)
    deliver_with_template_and_log(from: @@from_email,
                                  to: user.email,
                                  reply_to: 'support@civis.vote',
                                  template_alias: 'profane-response-notification',
                                  subject: 'Profane response flagged',
                                  module_name: 'ConsultationResponse',
                                  record: consultation_response,
                                  template_model: {
                                    user_name: consultation_response.user.first_name,
                                    consultation_title: consultation_response.consultation.title,
                                    product_url: Rails.application.config.client_url[:host]
                                  })
  end

  def notify_pending_review_of_profane_responses_email_to_admin(user, response_under_review_count, consultation_expiring_today_count, url)
    deliver_with_template_and_log(from: @@from_email,
                                  to: user.email,
                                  reply_to: 'support@civis.vote',
                                  template_alias: 'pending-review-of-profane-responses-notification',
                                  subject: 'Pending review of profane responses',
                                  module_name: 'ConsultationResponse',
                                  triggered_by_type: 'scheduled_job',
                                  template_model: {
                                    name: user.full_name,
                                    response_under_review_count: response_under_review_count,
                                    consultation_expiring_today_count: consultation_expiring_today_count,
                                    url: url,
                                    product_url: Rails.application.config.client_url[:host]
                                  })
  end

  def user_up_vote_responses_email_job(user, consultation_response)
    deliver_with_template_and_log(from: @@from_email,
                                  to: user.email,
                                  reply_to: 'support@civis.vote',
                                  template_alias: 'user-up-vote-responses-email',
                                  subject: 'Your response was upvoted',
                                  module_name: 'ConsultationResponse',
                                  record: consultation_response,
                                  triggered_by_type: 'scheduled_job',
                                  template_model: {
                                    up_vote_count: consultation_response.up_vote_count,
                                    consultation_response: consultation_response.response_text.to_plain_text,
                                    consultation_title: consultation_response.consultation.title,
                                    product_url: Rails.application.config.client_url[:host]
                                  })
  end

  def use_response_as_template_email_job(user, consultation_response)
    deliver_with_template_and_log(from: @@from_email,
                                  to: user.email,
                                  reply_to: 'support@civis.vote',
                                  template_alias: 'use-response-as-template-email',
                                  subject: 'Your response was used as a template',
                                  module_name: 'ConsultationResponse',
                                  record: consultation_response,
                                  triggered_by_type: 'scheduled_job',
                                  template_model: {
                                    templates_count: consultation_response.templates_count,
                                    consultation_response: consultation_response.response_text.to_plain_text,
                                    consultation_title: consultation_response.consultation.title,
                                    product_url: Rails.application.config.client_url[:host]
                                  })
  end

  def notify_published_consultation_email(consultation)
    deliver_with_template_and_log(from: @@from_email,
                                  to: consultation.created_by.email,
                                  reply_to: 'support@civis.vote',
                                  template_alias: 'notify-published-consultation',
                                  subject: "Consultation published: #{consultation.title}",
                                  module_name: 'Consultation',
                                  record: consultation,
                                  template_model: {
                                    first_name: consultation.created_by.first_name,
                                    consultation_name: consultation.title,
                                    feedback_url: consultation.feedback_url,
                                    unsubscribe_url: consultation.created_by.unsubscribe_url,
                                    product_url: Rails.application.config.client_url[:host]
                                  })
  end

  def notify_expired_consultation_email(email, consultation, officer_name = nil, officer_designation = nil)
    response = deliver_with_template_and_log(from: 'antaraa.vasudev@civis.vote',
                                             to: email,
                                             reply_to: 'support@civis.vote',
                                             template_alias: 'notify-expired-consultation',
                                             subject: "Consultation feedback report: #{consultation.title}",
                                             module_name: 'Consultation',
                                             record: consultation,
                                             triggered_by_type: 'scheduled_job',
                                             template_model: {
                                               first_name: consultation.created_by.first_name,
                                               consultation_name: consultation.title,
                                               responses: consultation.consultation_responses_count,
                                               ministry_name: consultation.department.name,
                                               officer_name: officer_name,
                                               officer_designation: officer_designation,
                                               response_url: consultation.response_url,
                                               product_url: Rails.application.config.client_url[:host]
                                             })
    consultation.update(feedback_email_message_id: response[:message_id])
  end

  def forgot_password_email(user, url)
    deliver_with_template_and_log(from: @@from_email,
                                  to: user.email,
                                  reply_to: 'support@civis.vote',
                                  template_alias: 'forgot-password',
                                  subject: 'Password reset request',
                                  module_name: 'User',
                                  record: user,
                                  triggered_by_type: 'user',
                                  triggered_by_id: user.id,
                                  template_model: {
                                    email: user.email,
                                    url: url,
                                    unsubscribe_url: user.unsubscribe_url,
                                    product_url: Rails.application.config.client_url[:host]
                                  })
  end

  def existing_user_email(user, password, client_url)
    deliver_with_template_and_log(from: @@from_email,
                                  to: user.email,
                                  reply_to: 'support@civis.vote',
                                  template_alias: 'invite-existing-user-with-credentials',
                                  subject: 'Your Civis account credentials',
                                  module_name: 'User',
                                  record: user,
                                  template_model: {
                                    first_name: user.first_name,
                                    email: user.email,
                                    password: password,
                                    url: client_url,
                                    unsubscribe_url: user.unsubscribe_url,
                                    product_url: Rails.application.config.client_url[:host]
                                  })
  end

  def consultation_export_email_job(consultations, email)
    size_arr = []
    consultations.size.times { size_arr << 22 }
    excel_file = "#{Dir.tmpdir}/consultations-sheet_#{Time.now}.xlsx"
    file_name = "consultations-sheet_#{Time.now}.xlsx"
    xlsx = Axlsx::Package.new
    xlsx.workbook.add_worksheet(name: 'Consultations') do |sheet|
      sheet.add_row ['Title', 'Url', 'Response Deadline', 'Ministry', 'Category', 'Status', 'Summary', 'Response Count', 'Featured', 'Reading Time', 'Created At', 'Consultation Page Link'], b: true
      consultations.each do |consultation|
        sheet.add_row [consultation.title, consultation.url, consultation.response_deadline&.strftime('%d %b %Y %I:%M %p'), consultation.department.name, consultation.department.theme&.name, consultation.status, consultation.english_summary_text, consultation.consultation_responses_count, consultation.is_featured, consultation.reading_time, consultation.created_at&.strftime('%d %b %Y'), consultation.feedback_url]
      end
      sheet.column_widths(*size_arr)
    end
    xlsx.serialize(excel_file)
    user = User.find_by(email: email)
    file = File.open(excel_file)
    deliver_with_template_and_log(from: @@from_email,
                                  to: user.email,
                                  reply_to: 'support@civis.vote',
                                  template_alias: 'export-spotlight-search',
                                  subject: 'Consultations export',
                                  module_name: 'Consultation',
                                  record: user,
                                  triggered_by_type: 'user',
                                  triggered_by_id: user.id,
                                  template_model: {
                                    first_name: user.first_name
                                  },
                                  attachments: [{
                                    name: file_name,
                                    content: [file.read].pack('m'),
                                    content_type: 'application/vnd.ms-excel',
                                    product_url: Rails.application.config.client_url[:host]
                                  }])
  end

  def	consultation_responses_export_email_job(consultation_responses, email)
    size_arr = []
    consultation_responses.size.times { size_arr << 22 }
    excel_file = "#{Dir.tmpdir}/consultation-responses-sheet_#{Time.now}.xlsx"
    file_name = "consultations-responses-sheet_#{Time.now}.xlsx"
    xlsx = Axlsx::Package.new
    if consultation_responses.last.consultation.public_consultation?
      xlsx.workbook do |workbook|
        workbook.add_worksheet(name: 'Consultation Responses') do |sheet|
          wrap = workbook.styles.add_style alignment: { wrap_text: true }
          response_header = ['Consultation Title', 'Category', 'Consultation Response Text', 'Submitted By', 'Responder Email', 'City', 'Phone Number', 'Satisfication Rating', 'Visibility', 'Submitted At', 'Is Verified', 'Source', 'Organisation/Department', 'Designation']
          question_headers = consultation_responses.last.consultation.response_rounds.last.questions.order(:created_at).pluck(:question_text)
          question_ids = consultation_responses.last.consultation.response_rounds.last.questions.order(:created_at).pluck(:id)
          question_headers.each do |question|
            response_header << question
          end
          sheet.add_row response_header, b: true
          consultation_responses.each do |consultation_response|
            row_data = [consultation_response.consultation.title, consultation_response.consultation.department.theme&.name, consultation_response.response_text.to_plain_text, consultation_response.user ? consultation_response.user.full_name : "#{consultation_response.first_name} #{consultation_response.last_name}", consultation_response.user ? consultation_response.user.email : consultation_response.email, consultation_response.user.present? && consultation_response.user.city.present? ? consultation_response.user.city.name : 'NA', consultation_response.user.present? && consultation_response.user.phone_number.present? ? consultation_response.user.phone_number : 'NA', consultation_response.satisfaction_rating, consultation_response.visibility, consultation_response.platform? ? consultation_response.created_at.localtime.try(:strftime, '%e %b %Y') : consultation_response.responded_at.try(:strftime, '%e %b %Y'), consultation_response.user ? consultation_response.user.confirmed_at? : nil, consultation_response.source, if consultation_response.user.present? && consultation_response.user.organisation.present?
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       consultation_response.user.organisation.name
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     elsif consultation_response.user.present? && consultation_response.user.organization.present?
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       consultation_response.user.organization
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     else
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       'NA'
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     end, consultation_response.user.present? && consultation_response.user.designation.present? ? consultation_response.user.designation : 'NA']
            answers = []
            question_ids.each do |id|
              answers << if consultation_response.answers.present? && answer = consultation_response.answers.find { |ans| ans['question_id'].to_i == id }
                           answer
                         else
                           ''
                         end
            end
            answers = answers.map do |k|
              "#{if k['answer'].class == Array
                   k['answer'].map { |sub_question| Question.find(sub_question).question_text }.join(',')
                 else
                   k['answer'].class == Integer ? Question.find(k['answer']).question_text : k['answer']
                 end}#{if k.empty?
                         ''
                       else
                         k.key?('is_other') && k['answer'].present? ? ',' : ' '
                       end}#{if k.empty?
                               ''
                             else
                               k.key?('is_other') ? k['other_option_answer'] : ''
                             end}"
            end
            answers.each do |answer|
              row_data << answer
            end
            sheet.add_row row_data, style: wrap
          end
          sheet.column_widths(*size_arr)
        end
      end
    else
      xlsx.workbook do |workbook|
        consultation_responses.last.consultation.response_rounds.order(:created_at).each_with_index do |response_round, index|
          next unless response_round.present?
          workbook.add_worksheet(name: "Responses - Round #{index + 1}") do |sheet|
            wrap = workbook.styles.add_style alignment: { wrap_text: true }
            response_header = ['Consultation Title', 'Category', 'Consultation Response Text', 'Submitted By', 'Responder Email', 'City', 'Phone Number', 'Satisfication Rating', 'Visibility', 'Submitted At', 'Is Verified', 'Source', 'Organisation/Department', 'Designation']
            question_headers = response_round.questions.order(:created_at).pluck(:question_text)
            question_ids = response_round.questions.order(:created_at).pluck(:id)
            question_headers.each do |question|
              response_header << question
            end
            sheet.add_row response_header, b: true
            consultation_responses.each do |consultation_response|
                next unless consultation_response.response_round_id == response_round.id

                row_data = [consultation_response.consultation.title, consultation_response.consultation.department.theme&.name, consultation_response.response_text.to_plain_text, consultation_response.user ? consultation_response.user.full_name : "#{consultation_response.first_name} #{consultation_response.last_name}", consultation_response.user ? consultation_response.user.email : consultation_response.email, consultation_response.user.present? && consultation_response.user.city.present? ? consultation_response.user.city.name : 'NA', consultation_response.user.present? && consultation_response.user.phone_number.present? ? consultation_response.user.phone_number : 'NA', consultation_response.satisfaction_rating, consultation_response.visibility, consultation_response.created_at.localtime.try(:strftime, '%e %b %Y'), consultation_response.user ? consultation_response.user.confirmed_at? : nil, consultation_response.source, if consultation_response.user.present? && consultation_response.user.organisation.present?
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         consultation_response.user.organisation.name
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       elsif consultation_response.user.present? && consultation_response.user.organization.present?
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         consultation_response.user.organization
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       else
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         'NA'
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       end, consultation_response.user.present? && consultation_response.user.designation.present? ? consultation_response.user.designation : 'NA']
                answers = []
                question_ids.each do |id|
                  answers << if consultation_response.answers.present? && answer = consultation_response.answers.find { |ans| ans['question_id'].to_i == id }
                               answer
                             else
                               ''
                             end
                end
                answers = answers.map do |k|
                  "#{if k['answer'].class == Array
                       k['answer'].map { |sub_question| Question.find(sub_question).question_text }.join(',')
                   else
                     k['answer'].class == Integer ? Question.find(k['answer']).question_text : k['answer']
                   end}#{if k.empty?
                           ''
                         else
                           k.key?('is_other') && k['answer'].present? ? ',' : ' '
                         end}#{if k.empty?
                                 ''
                               else
                                 k.key?('is_other') ? k['other_option_answer'] : ''
                               end}"
                end
                answers.each do |answer|
                  row_data << answer
                end
                sheet.add_row row_data, style: wrap
              end
            sheet.column_widths(*size_arr)
          end
        end
      end
    end
    xlsx.use_shared_strings = true
    xlsx.serialize(excel_file)
    user = User.find_by(email: email)
    file = File.open(excel_file)
    deliver_with_template_and_log(from: @@from_email,
                                  to: user.email,
                                  reply_to: 'support@civis.vote',
                                  template_alias: 'export-spotlight-search',
                                  subject: 'Consultation responses export',
                                  module_name: 'ConsultationResponse',
                                  record: user,
                                  triggered_by_type: 'user',
                                  triggered_by_id: user.id,
                                  template_model: {
                                    first_name: user.first_name
                                  },
                                  attachments: [{
                                    name: file_name,
                                    content: [file.read].pack('m'),
                                    content_type: 'application/vnd.ms-excel',
                                    product_url: Rails.application.config.client_url[:host]
                                  }])
  end

  def user_export_email_job(users, email)
    size_arr = []
    users.size.times { size_arr << 22 }
    excel_file = "#{Dir.tmpdir}/users-sheet_#{Time.now}.xlsx"
    file_name = "users-sheet_#{Time.now}.xlsx"
    xlsx = Axlsx::Package.new
    xlsx.workbook do |workbook|
      workbook.add_worksheet(name: 'Users') do |sheet|
        center = workbook.styles.add_style alignment: { horizontal: :center, vertical: :center }
        sheet.add_row ['First Name', 'Last Name', 'Email', 'Points', 'Rank', 'Best Rank', 'Best Rank Type', 'State Rank', 'City', 'City Type', 'Created At', 'Subscribed', 'Role', 'Phone Number', 'Email Verified', 'Signup Through', 'Last Active At', 'Organisation/Department', 'Designation'], b: true
        users.each do |user|
          sheet.add_row [user.format_for_csv('first_name'), user.format_for_csv('last_name'), user.email, user.format_for_csv('points'), user.format_for_csv('rank'), user.format_for_csv('best_rank'), user.format_for_csv('best_rank_type'), user.format_for_csv('state_rank'), user.city.present? ? user.city.name : 'NA', user.city.present? ? user.city.location_type : 'NA', user.format_for_csv('created_at').strftime('%d %b %Y'), user.notify_for_new_consultation.present? ? 'true' : 'false', user.role, user.format_for_csv('phone_number'), user.confirmed?, user.provider || 'email', user.format_for_csv('last_activity_at').strftime('%d %b %Y'), if user.organisation.present?
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    user.organisation.name
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  elsif user.organization.present?
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    user.organization
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  else
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    'NA'
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  end, user.designation.present? ? user.designation : 'NA'], style: [center] * 14
        end
        sheet.column_widths(*size_arr)
      end
    end
    xlsx.serialize(excel_file)
    user = User.find_by(email: email)
    file = File.open(excel_file)
    deliver_with_template_and_log(from: @@from_email,
                                  to: user.email,
                                  reply_to: 'support@civis.vote',
                                  template_alias: 'export-spotlight-search',
                                  subject: 'Users export',
                                  module_name: 'User',
                                  record: user,
                                  triggered_by_type: 'user',
                                  triggered_by_id: user.id,
                                  template_model: {
                                    first_name: user.first_name
                                  },
                                  attachments: [{
                                    name: file_name,
                                    content: [file.read].pack('m'),
                                    content_type: 'application/vnd.ms-excel',
                                    product_url: Rails.application.config.client_url[:host]
                                  }])
  end

  def profanity_export_email_job(profanities, email)
    size_arr = []
    profanities.size.times { size_arr << 22 }
    excel_file = "#{Dir.tmpdir}/profanities-sheet_#{Time.now}.xlsx"
    file_name = "profanities-sheet_#{Time.now}.xlsx"
    xlsx = Axlsx::Package.new
    xlsx.workbook do |workbook|
      workbook.add_worksheet(name: 'Profanities') do |sheet|
        center = workbook.styles.add_style alignment: { horizontal: :center, vertical: :center }
        sheet.add_row ['Profane Word'], b: true
        profanities.each do |profanity|
          sheet.add_row [profanity.format_for_csv('profane_word')], style: [center] * 1
        end
        sheet.column_widths(*size_arr)
      end
    end
    xlsx.serialize(excel_file)
    user = User.find_by(email: email)
    file = File.open(excel_file)
    deliver_with_template_and_log(from: @@from_email,
                                  to: user.email,
                                  reply_to: 'support@civis.vote',
                                  template_alias: 'export-spotlight-search',
                                  subject: 'Profanity export',
                                  module_name: 'Profanity',
                                  record: user,
                                  triggered_by_type: 'user',
                                  triggered_by_id: user.id,
                                  template_model: {
                                    first_name: user.first_name
                                  },
                                  attachments: [{
                                    name: file_name,
                                    content: [file.read].pack('m'),
                                    content_type: 'application/vnd.ms-excel',
                                    product_url: Rails.application.config.client_url[:host]
                                  }])
  end

  def wordindex_export_email_job(wordindices, email)
    size_arr = []
    wordindices.size.times { size_arr << 22 }
    excel_file = "#{Dir.tmpdir}/glossary-sheet_#{Time.now}.xlsx"
    file_name = "glossary-sheet_#{Time.now}.xlsx"
    xlsx = Axlsx::Package.new
    xlsx.workbook do |workbook|
      workbook.add_worksheet(name: 'Glossary') do |sheet|
        center = workbook.styles.add_style alignment: { horizontal: :left, vertical: :center }
        sheet.add_row %w[Word Description], b: true
        wordindices.each do |wordindex|
          sheet.add_row [wordindex.format_for_csv('word'), wordindex.format_for_csv('description')], style: [center] * 2
        end
        sheet.column_widths(*size_arr)
      end
    end
    xlsx.serialize(excel_file)
    user = User.find_by(email: email)
    file = File.open(excel_file)
    deliver_with_template_and_log(from: @@from_email,
                                  to: user.email,
                                  reply_to: 'support@civis.vote',
                                  template_alias: 'export-spotlight-search',
                                  subject: 'Glossary export',
                                  module_name: 'Wordindex',
                                  record: user,
                                  triggered_by_type: 'user',
                                  triggered_by_id: user.id,
                                  template_model: {
                                    first_name: user.first_name
                                  },
                                  attachments: [{
                                    name: file_name,
                                    content: [file.read].pack('m'),
                                    content_type: 'application/vnd.ms-excel',
                                    product_url: Rails.application.config.client_url[:host]
                                  }])
  end

  def invite_organisation_employee(user, invitation_url)
    deliver_with_template_and_log(from: @@from_email,
                                  to: user.email,
                                  reply_to: 'support@civis.vote',
                                  template_alias: 'organisation-user-invite',
                                  subject: 'Organisation invitation',
                                  module_name: 'User',
                                  record: user,
                                  template_model: {
                                    first_name: user.first_name,
                                    invitation_url: invitation_url,
                                    unsubscribe_url: user.unsubscribe_url
                                  })
  end

  def invite_respondent(consultation, user, consultation_url)
    deliver_with_template_and_log(from: @@from_email,
                                  to: user.email,
                                  reply_to: 'support@civis.vote',
                                  template_alias: 'invite-respondent',
                                  subject: 'Respondent invitation',
                                  module_name: 'Consultation',
                                  record: consultation,
                                  template_model: {
                                    consultation_name: consultation.title,
                                    consultation_url: consultation_url,
                                    unsubscribe_url: user.unsubscribe_url,
                                    product_url: Rails.application.config.client_url[:host]
                                  })
  end

  def export_all_subjective_responses(email)
    consultation_list = Consultation.includes(responses: { user: :city }, response_rounds: :questions)
    question_ids = Question.where(question_type: 'long_text').pluck(:id)
    excel_file = "#{Dir.tmpdir}/consultation-responses-sheet_#{Time.now}.xlsx"
    file_name = "consultations-responses-sheet_#{Time.now}.xlsx"
    xlsx = Axlsx::Package.new
    response_header = ['Consultation Title', 'Category', 'Consultation Response Text', 'Submitted By', 'Responder Email', 'City', 'Phone Number', 'Satisfication Rating', 'Visibility', 'Submitted At', 'Is Verified', 'Source', 'Organisation/Department', 'Designation']
    xlsx.workbook do |workbook|
      workbook.add_worksheet(name: 'Consultation Responses') do |sheet|
        wrap = workbook.styles.add_style alignment: { wrap_text: true }
        sheet.add_row response_header, b: true
        size_arr = []
        consultation_list.each do |consultation|
          next if consultation.response_rounds.last.questions.count != 0 && (question_ids & consultation.response_rounds.last.questions.pluck(:id)).empty?

          consultation_responses = consultation.responses
          consultation_responses.size.times { size_arr << 22 }
          consultation_responses.each do |consultation_response|
            row_data = [consultation_response.consultation.title, consultation_response.consultation.department.theme&.name, response_text(consultation_response, question_ids), consultation_response.user ? consultation_response.user.full_name : "#{consultation_response.first_name} #{consultation_response.last_name}", consultation_response.user ? consultation_response.user.email : consultation_response.email, consultation_response.user.present? && consultation_response.user.city.present? ? consultation_response.user.city.name : 'NA', consultation_response.user.present? && consultation_response.user.phone_number.present? ? consultation_response.user.phone_number : 'NA', consultation_response.satisfaction_rating, consultation_response.visibility, consultation_response.platform? ? consultation_response.created_at.localtime.try(:strftime, '%e %b %Y') : consultation_response.responded_at.try(:strftime, '%e %b %Y'), consultation_response.user ? consultation_response.user.confirmed_at? : nil, consultation_response.source, if consultation_response.user.present? && consultation_response.user.organisation.present?
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        consultation_response.user.organisation.name
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      elsif consultation_response.user.present? && consultation_response.user.organization.present?
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        consultation_response.user.organization
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      else
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        'NA'
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      end, consultation_response.user.present? && consultation_response.user.designation.present? ? consultation_response.user.designation : 'NA']
            sheet.add_row row_data, style: wrap
          end
          sheet.column_widths(*size_arr)
        end
      end
    end
    xlsx.use_shared_strings = true
    xlsx.serialize(excel_file)
    user = User.find_by(email: email)
    file = File.open(excel_file)
    deliver_with_template_and_log(from: @@from_email,
                                  to: user.email,
                                  reply_to: 'support@civis.vote',
                                  template_alias: 'export-spotlight-search',
                                  subject: 'Subjective responses export',
                                  module_name: 'ConsultationResponse',
                                  record: user,
                                  triggered_by_type: 'user',
                                  triggered_by_id: user.id,
                                  template_model: {
                                    first_name: user.first_name
                                  },
                                  attachments: [{
                                    name: file_name,
                                    content: [file.read].pack('m'),
                                    content_type: 'application/vnd.ms-excel',
                                    product_url: Rails.application.config.client_url[:host]
                                  }])
  end

  def response_text(response, question_ids)
    response.response_text.to_plain_text.presence || (response.answers && response.answers.detect { |an| question_ids.include? an['question_id'].to_i }&.dig('answer'))
  end

  def send_otp(user)
    otp = user.otp_requests.active.last&.otp
    return unless otp

    deliver_with_template_and_log(
      from: @@from_email,
      to: user.email,
      template_alias: 'otp-verification',
      subject: 'OTP verification',
      module_name: 'User',
      record: user,
      triggered_by_type: 'user',
      triggered_by_id: user.id,
      template_model: template_model_base.merge!({ name: user.first_name,
                                                   product_url: Rails.application.config.client_url[:host],
                                                   otp: otp,
                                                   otp_first: otp.to_s[0, 3],
                                                   otp_second: otp.to_s[3, 3]})
    )
  end

  private

  def deliver_with_template_and_log(subject:, module_name:, record: nil, triggered_by_type: 'system',
                                    triggered_by_id: nil, **postmark_args)
    response = @@postmark_client.deliver_with_template(**postmark_args)
    create_cm_email_log(message_id: response[:message_id], subject:, module_name:, record:,
                        triggered_by_type:, triggered_by_id:, postmark_args:)
    response
  end

  def create_cm_email_log(message_id:, subject:, module_name:, record:, triggered_by_type:,
                          triggered_by_id:, postmark_args:)
    return unless CmAdmin.config.enable_email_logging

    CmEmailLog.create(
      message_id: message_id,
      to: [{ 'email' => postmark_args[:to], 'status' => 'processed', 'processed_at' => Time.current.iso8601 }],
      from_email: email_log_sender_email(postmark_args[:from]),
      reply_to: postmark_args[:reply_to],
      subject: subject,
      template_name: postmark_args[:template_alias],
      module_name: module_name,
      record: record,
      record_url: email_log_record_url(record),
      triggered_by_type: triggered_by_type,
      triggered_by_id: triggered_by_id,
      sent_at: Time.current,
      status: :processing
    )
  rescue => e
    Airbrake.notify(e, context: { message: 'CmEmailLog creation failed' }) if defined?(Airbrake)
    Rails.logger.error("CmEmailLog creation failed: #{e.class} #{e.message}")
    nil
  end

  def email_log_sender_email(raw_from)
    raw_from.to_s.match(/<([^>]+)>/)&.[](1) || raw_from
  end

  def email_log_record_url(record)
    helper = "cm_show_#{record.class.name.underscore}_path"
    url_helpers = CmAdmin::Engine.routes.url_helpers
    url_helpers.public_send(helper, record) if url_helpers.respond_to?(helper)
  end
end
