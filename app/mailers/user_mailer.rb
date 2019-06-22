class UserMailer < ApplicationMailer

	def verify_email(user)
		@@postmark_client.deliver_with_template(from: 'support@civis.vote',
																						to: user.email,
																						template_alias: "user-confirmation",
																						template_model:{
																							first_name: user.first_name,
																							confirmation_url: user.confirmation_url
																						})

	end

end