class AddOptionalToQuestion < ActiveRecord::Migration[6.0]
  def self.up
    add_column :questions, :is_optional, :boolean, default: false
  end
  def self.down
  	remove_column :questions, :optional, :boolean, default: false
  end
end
