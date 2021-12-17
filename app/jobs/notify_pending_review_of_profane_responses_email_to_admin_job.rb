class NotifyPendingReviewOfProfaneResponsesEmailToAdminJob < ApplicationJob
  queue_as :default

  def perform(consultation)
  	::User.where(role: [:admin]).each do |user|
      begin
    	 UserMailer.notify_pending_review_of_profane_responses_email_to_admin(user, consultation).deliver_now
      rescue
        puts "Failed to deliver email for User - #{user.id}"
      end
    end
  end
end
