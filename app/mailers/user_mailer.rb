class UserMailer < ApplicationMailer

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
end