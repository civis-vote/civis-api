class AddConsultationTitleToUserNotification < ActiveRecord::Migration[6.0]
  def change
    add_column :user_notifications, :consultation_title, :string
  end
end
