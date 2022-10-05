class RemoveRankFieldsFromUserNotifications < ActiveRecord::Migration[6.0]
  def change
    remove_column :user_notifications, :city_rank, :integer
    remove_column :user_notifications, :state_rank, :integer
    remove_column :user_notifications, :national_rank, :integer
  end
end
