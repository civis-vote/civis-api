class UserMailer < ApplicationMailer
	require 'axlsx'

	def verify_email(user)
		@@postmark_client.deliver_with_template(from: 'Civis'+ unless Rails.env.production? then +' - ' + Rails.env.titleize else '' end  + '<support@civis.vote>',
																						to: user.email,
																						template_alias: "user-confirmation",
																						template_model:{
																							first_name: user.first_name,
																							confirmation_url: user.confirmation_url,
																							unsubscribe_url: user.unsubscribe_url
																						})

	end

	def notify_new_consultation_email(user, consultation)
		@@postmark_client.deliver_with_template(from: 'Civis'+ unless Rails.env.production? then +' - ' + Rails.env.titleize else '' end  + '<support@civis.vote>',
																						to: user.email,
																						template_alias: "notify-new-consultation",
																						template_model:{
																							first_name: user.first_name,
																							consultation_name: consultation.title,
																							days_left: consultation.days_left,
																							ministry_name: consultation.ministry.name,
																							feedback_url: consultation.feedback_url,
																							unsubscribe_url: user.unsubscribe_url
																						})
	end

	def notify_published_consultation_email(consultation)
		@@postmark_client.deliver_with_template(from: 'Civis'+ unless Rails.env.production? then +' - ' + Rails.env.titleize else '' end  + '<support@civis.vote>',
																						to: consultation.created_by.email,
																						template_alias: "notify-published-consultation",
																						template_model:{
																							first_name: consultation.created_by.first_name,
																							consultation_name: consultation.title,
																							feedback_url: consultation.feedback_url,
																							unsubscribe_url: consultation.created_by.unsubscribe_url
																						})
	end

	def notify_expired_consultation_email(email, consultation)
		@@postmark_client.deliver_with_template(from: 'Civis'+ unless Rails.env.production? then +' - ' + Rails.env.titleize else '' end  + '<support@civis.vote>',
																						to: email,
																						template_alias: "notify-expired-consultation",
																						template_model:{
																							first_name: consultation.created_by.first_name,
																							consultation_name: consultation.title,
																							responses: consultation.consultation_responses_count,
																							ministry_name: consultation.ministry.name,
																							response_url: consultation.response_url
																						})
	end

	def forgot_password_email(user, url)
		@@postmark_client.deliver_with_template(from: 'Civis'+ unless Rails.env.production? then +' - ' + Rails.env.titleize else '' end  + '<support@civis.vote>',
																							to: user.email,
																							template_alias: "forgot-password",
																							template_model:{
																								email: user.email,
																								url: url,
																								unsubscribe_url: user.unsubscribe_url
																							})
	end

	def existing_user_email(user, password, client_url)
		@@postmark_client.deliver_with_template(from: 'Civis'+ unless Rails.env.production? then +' - ' + Rails.env.titleize else '' end  + '<support@civis.vote>',
																							to: user.email,
																							template_alias: "invite-existing-user-with-credentials",
																							template_model:{
																								first_name: user.first_name,
																								email: user.email,
																								password: password,
																								url: client_url,
																								unsubscribe_url: user.unsubscribe_url
																							})
	end

	def consultation_export_email_job(consultations, email)
		size_arr = []
    consultations.size.times { size_arr << 22 }
		excel_file = "#{Dir.tmpdir()}/consultations-sheet_#{Time.now.to_s}.xlsx"
		file_name = "consultations-sheet_#{Time.now.to_s}.xlsx"
		xlsx = Axlsx::Package.new
		xlsx.workbook.add_worksheet(name: "Consultations") do |sheet|
		  sheet.add_row ["Title", "Url", "Response Deadline", "Ministry", "Status", "Summary", "Response Count", "Featured", "Reading Time", "Created At"], b: true
		  consultations.each do |consultation|
		    sheet.add_row [consultation.title, consultation.url, consultation.response_deadline, consultation.ministry.name, consultation.status, consultation.summary.to_plain_text, consultation.consultation_responses_count, consultation.is_featured, consultation.reading_time, consultation.created_at]
		  end
			sheet.column_widths *size_arr
		end
    xlsx.serialize(excel_file)
    user = User.find_by(email: email)
    file = File.open(excel_file)
		@@postmark_client.deliver_with_template(from: 'Civis'+ unless Rails.env.production? then +' - ' + Rails.env.titleize else '' end  + '<support@civis.vote>',
																						to: user.email,
																						template_id: 13651891,
																						template_model:{
																							first_name: user.first_name
																						},
                                              attachments: [{
                                                name: file_name,
                                                content: [file.read].pack('m'),
                                                content_type: 'application/vnd.ms-excel'
                                              }]
                                            )
	end

	def consultation_responses_export_email_job(consultation_responses, email)
		size_arr = []
    consultation_responses.size.times { size_arr << 22 }
		excel_file = "#{Dir.tmpdir()}/consultation-responses-sheet_#{Time.now.to_s}.xlsx"
		file_name = "consultations-responses-sheet_#{Time.now.to_s}.xlsx"
		xlsx = Axlsx::Package.new
		xlsx.workbook.add_worksheet(name: "Consultation Responses") do |sheet|
		  sheet.add_row ["Consultation Title", "Consultation Response Text", "Submitted By", "Satisfication Rating", "Visibility", "Submitted At"], b: true
		  consultation_responses.each do |consultation_response|
		    sheet.add_row [consultation_response.consultation.title, consultation_response.response_text, consultation_response.user.full_name, consultation_response.satisfaction_rating, consultation_response.visibility, consultation_response.created_at]
		  end
			sheet.column_widths *size_arr
		end
    xlsx.serialize(excel_file)
    user = User.find_by(email: email)
    file = File.open(excel_file)
		@@postmark_client.deliver_with_template(from: 'Civis'+ unless Rails.env.production? then +' - ' + Rails.env.titleize else '' end  + '<support@civis.vote>',
																						to: user.email,
																						template_id: 13651891,
																						template_model:{
																							first_name: user.first_name
																						},
                                              attachments: [{
                                                name: file_name,
                                                content: [file.read].pack('m'),
                                                content_type: 'application/vnd.ms-excel'
                                              }]
                                            )
	end

end