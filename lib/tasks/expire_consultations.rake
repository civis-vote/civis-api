namespace :expire do
  desc "Update consultation status"
  task consultations: :environment do
    Consultation.published.where("response_deadline < ?", Date.today).update(status: :expired)
  end
end