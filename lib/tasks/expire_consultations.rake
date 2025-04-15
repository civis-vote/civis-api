namespace :expire do
  desc "Update consultation status"
  task consultations: :environment do
    Consultation.published.where("response_deadline <= ?", Time.current.in_time_zone("Asia/Kolkata")).each(&:expire)
  end
end
