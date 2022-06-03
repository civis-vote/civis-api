class AddConsultationIdToUserNotification < ActiveRecord::Migration[6.0]
  def change
    add_column :user_notifications, :consultation_id, :integer, default: 0
  end
end
