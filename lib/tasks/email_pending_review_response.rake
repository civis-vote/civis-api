namespace :email do
  desc 'Send reminder email to all admins to review pending profane responses'
  task review_pending_profane_response: :environment do
    NotifyPendingReviewOfProfaneResponsesEmailToAdminJob.perform_later if ::ConsultationResponse.under_review.any?
  end
end
