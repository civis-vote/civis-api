namespace :email do
  desc 'Send reminder email to all admins to review pending profane responses'
  task review_pending_profane_response: :environment do
    if ::ConsultationResponse.under_review.any?
      consultations = Consultation.joins(:responses).where(consultation_responses: {response_status: 1}).distinct
      NotifyPendingReviewOfProfaneResponsesEmailToAdminJob.perform_later(consultations)
    end
  end
end
