namespace :expire do
  desc "Update consultation status"
  task consultations: :environment do
    Consultation.where("status = ? AND response_deadline < ?", Consultation.statuses[:submitted], Date.today).update(status: :expired)
  end
end