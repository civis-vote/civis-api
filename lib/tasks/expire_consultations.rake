namespace :expire do
  desc "Update consultation status"
  task consultations: :environment do
    shifted_time = Time.current.utc + 5.5.hours # NOTE: Adjusting for IST (UTC+5:30), response_deadline is in UTC
    Consultation.published.where("response_deadline <= ?", shifted_time).each(&:expire)
  end
end
