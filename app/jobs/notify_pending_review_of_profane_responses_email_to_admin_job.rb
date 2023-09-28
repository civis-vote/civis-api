class NotifyPendingReviewOfProfaneResponsesEmailToAdminJob < ApplicationJob
  queue_as :default

  def perform
    response_under_review_count = ::ConsultationResponse.under_review.size
    return if response_under_review_count.zero?

    url = Rails.application.routes.url_helpers.admin_consultation_responses_url(filters: { response_filter: 1 })
    consultation_expiring_today_count = ::Consultation.joins(:responses)
                                                      .where('DATE(response_deadline) <= ?', Date.today)
                                                      .where(consultation_responses: {response_status: 1})
                                                      .distinct.size
    # Set the value to nil so that the conditional statement can be added in the postmark template.
    consultation_expiring_today_count = nil if consultation_expiring_today_count.zero?
    ::User.where(role: [:admin]).each do |user|
      begin
        UserMailer.notify_pending_review_of_profane_responses_email_to_admin(user, response_under_review_count, consultation_expiring_today_count, url).deliver_now
      rescue
        puts "Failed to deliver email for User - #{user.id}"
      end
    end
  end
end
