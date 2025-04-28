class ShowDiscussEngageTab < ActiveRecord::Migration[7.1]
  def change
    add_column :consultations, :allow_discuss_engage_response, :boolean, default: true, null: false
  end
end
