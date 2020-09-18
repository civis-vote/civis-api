require "tzinfo"
# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :output, "log/cron_log.log"
env :PATH, ENV["PATH"]

def local(time)
	TZInfo::Timezone.get("Asia/Kolkata").local_to_utc(Time.parse(time))
end

job_type :civis_backup,    "cd :path && :task :output"

every :day, at: local("12:00AM") do
  rake "expire:consultations"
  rake "sitemap:refresh"
	command "/usr/local/bin/backup perform -t civis_backup"
end