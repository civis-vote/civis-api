namespace :send_consultation_responses do
  desc "Send all subjective responses"
  task :export_subjective_responses, [:email] => [:environment] do |t, args|
    UserMailer.export_all_subjective_responses(args[:email]).deliver_now
  end
end
