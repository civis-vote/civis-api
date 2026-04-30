class CreateCmSupportTickets < ActiveRecord::Migration[8.1]
  def change
    create_table :cm_support_tickets do |t|
      t.string :name
      t.text :description
      t.references :created_by, foreign_key: { to_table: :users }
      t.string :created_by_name
      t.citext :created_by_email
      t.string :cm_admin_version
      t.string :browser_name
      t.string :browser_version
      t.integer :cm_bridge_ticket_id
      t.integer :platform_ticket_id
      t.integer :cm_admin_installation_id
      t.integer :platform_status, default: 0
      t.integer :bridge_status, default: 0
      t.integer :priority, default: 0
      t.references :updated_by, foreign_key: { to_table: :users }
      t.string :updated_by_name

      t.timestamps
    end
  end
end
