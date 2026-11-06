class RemoveReadSuffixFromUserCallbackUrls < ActiveRecord::Migration[8.1]
  def up
    User.where("callback_url LIKE ?", "%/consultations/%/read").find_each do |user|
      user.update_columns(callback_url: user.callback_url.sub(%r{/read\z}, ""))
    end
  end
end
