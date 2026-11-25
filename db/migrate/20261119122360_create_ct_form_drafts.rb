class CreateCtFormDrafts < ActiveRecord::Migration[8.1]
  def up
    create_table :ct_form_drafts do |t|
      t.references :owner, polymorphic: true, null: false
      t.string :form_id, null: false
      t.string :ar_model_name, null: false
      t.string :ar_action_name, null: false
      t.string :record_id, null: false, default: 'new'
      t.jsonb :data, default: {}
      t.jsonb :attachments, default: {}
      t.integer :step_index
      t.datetime :expiry_at

      t.timestamps
    end

    add_index :ct_form_drafts, :form_id, unique: true

    execute <<~SQL
      INSERT INTO cm_cron_jobs (name, cron_string, command, status, created_at, updated_at)
      SELECT 'Clean expired form drafts', '@daily',
             'bin/rails runner "CtFormDraft.where(''expiry_at <= ?'', Time.current).destroy_all"',
             1, NOW(), NOW()
      WHERE NOT EXISTS (SELECT 1 FROM cm_cron_jobs WHERE name = 'Clean expired form drafts')
    SQL
  end

  def down
    execute "DELETE FROM cm_cron_jobs WHERE name = 'Clean expired form drafts'"
    drop_table :ct_form_drafts
  end
end
