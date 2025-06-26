class CreateCmCronJobLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :cm_cron_job_logs do |t|
      t.references :cron_job, null: false, foreign_key: { to_table: :cm_cron_jobs }
      t.integer :status, null: false, default: 0
      t.text :execution_log
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end
  end
end
