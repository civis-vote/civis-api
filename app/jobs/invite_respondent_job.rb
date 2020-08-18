class InviteRespondentJob < ApplicationJob
  queue_as :default

  def perform(consultation, user, consultation_url)
    UserMailer.invite_respondent(consultation, user, consultation_url).deliver_now
  end
end
