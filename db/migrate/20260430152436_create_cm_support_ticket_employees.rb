class CreateCmSupportTicketEmployees < ActiveRecord::Migration[8.1]
  def change
    create_table :cm_support_ticket_employees do |t|
      t.references :cm_support_ticket, null: false, foreign_key: true
      t.integer :employee_id, null: false
      t.timestamps
    end
  end
end
