class AddConsultationIdToUsernotification < ActiveRecord::Migration[6.0]
  def change
    add_column :user_notifications, :consultation_id, :Integer, default: false
  end
end
