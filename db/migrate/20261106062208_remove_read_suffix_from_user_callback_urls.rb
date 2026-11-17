class RemoveReadSuffixFromUserCallbackUrls < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      UPDATE users
      SET callback_url = LEFT(callback_url, LENGTH(callback_url) - 5)
      WHERE callback_url LIKE '%/consultations/%/read'
    SQL
  end
end
