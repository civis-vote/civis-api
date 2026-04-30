class AddCreatedByToCmComments < ActiveRecord::Migration[8.1]
  def change
    add_column :cm_comments, :created_by_name, :string
    add_column :cm_comments, :created_by_email, :citext
  end
end
