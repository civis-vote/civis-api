class AddDefaultValueToNotificationSetting < ActiveRecord::Migration[7.1]
  def change
    change_column_default :users, :notification_settings, from: nil, to: { 'notify_for_new_consultation': true,
                                                                           'newsletter_subscription': true }
  end
end
