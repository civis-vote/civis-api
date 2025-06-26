class CreateCmCronJobs < ActiveRecord::Migration[7.1]
  def change
    create_table :cm_cron_jobs do |t|
      t.string :name, null: false
      t.string :command, null: false
      t.string :cron_string, null: false
      t.datetime :last_run_at
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
