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

env :PATH, ENV["PATH"]

def local(time)
	TZInfo::Timezone.get("Asia/Kolkata").local_to_utc(Time.parse(time))
end

job_type :stack_path,    "cd $STACK_PATH && :task"

every :day, at: local('12:00am') do
  stack_path "bundle exec rails sitemap:refresh"
  stack_path "backup perform -t civis_backup"
end

every :day, at: local('10:00am') do
  rake 'email:review_pending_profane_response'
end
