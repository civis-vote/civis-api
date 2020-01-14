namespace :expire do
  desc "Update consultation status"
  task consultations: :environment do
    Consultation.published.where("Date(response_deadline) <= ?", Date.today).each do |consultation|
    	consultation.expire
    end 
  end
end