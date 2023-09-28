class UseResponseAsTemplateEmailJob < ApplicationJob
  queue_as :default

  def perform(consultation)
    consultation.responses.where("templates_count > ?",0).each do |response|
      user=User.find(response.user_id)
      begin
        UserMailer.use_response_as_template_email_job(user, response).deliver_now
      rescue
        puts "Failed to deliver email for User - #{user.id}"
      end
    end
  end
end
