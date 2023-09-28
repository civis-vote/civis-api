class UserUpVoteResponsesEmailJob < ApplicationJob
  queue_as :default

  def perform(consultation)
  	consultation.responses.where("up_vote_count > ?",0).each do |response|
      user = User.find(response.user_id)
      begin
    	 UserMailer.user_up_vote_responses_email_job(user, response).deliver_now
      rescue
        puts "Failed to deliver email for User - #{user.id}"
      end
    end
  end
end
