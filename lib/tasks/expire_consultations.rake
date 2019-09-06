namespace :expire do
  desc "Update consultation status"
  task consultations: :environment do
    Consultation.where("(status = ?) OR (status = ?) AND response_deadline < ?", Consultation.statuses[:submitted], Consultation.statuses[:published], Date.today).update(status: :expired)
  end
end