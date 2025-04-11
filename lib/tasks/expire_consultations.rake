namespace :expire do
  desc "Update consultation status"
  task consultations: :environment do
    Consultation.published.where("response_deadline <= ?", DateTime.current).each(&:expire)
  end
end
