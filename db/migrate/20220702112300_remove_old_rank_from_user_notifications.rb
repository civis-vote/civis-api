class RemoveOldRankFromUserNotifications < ActiveRecord::Migration[6.0]
  def change
    remove_column :user_notifications, :old_rank, :integer
    add_column :user_notifications, :city_rank, :integer
    add_column :user_notifications, :state_rank, :integer
    add_column :user_notifications, :national_rank, :integer
  end
end
