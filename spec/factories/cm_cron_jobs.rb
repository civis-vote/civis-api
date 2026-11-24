FactoryBot.define do
  factory :cm_cron_job do
    name { "Cron Job #{SecureRandom.hex(6)}" }
    command { 'echo test' }
    cron_string { '0 0 * * *' }
  end

  factory :cm_cron_job_log do
    cron_job { association :cm_cron_job }
    status { :success }
    started_at { Time.current }
    completed_at { Time.current + 1.minute }
  end
end
