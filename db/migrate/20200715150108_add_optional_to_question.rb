class AddOptionalToQuestion < ActiveRecord::Migration[6.0]
  def change
    add_column :questions, :optional, :boolean, default: false
  end
end
