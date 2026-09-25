class AddNotificationEmailsToCmCronJobs < ActiveRecord::Migration[8.1]
  def change
    add_column :cm_cron_jobs, :notification_emails, :text
  end
end
