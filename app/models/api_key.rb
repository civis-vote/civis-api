class ApiKey < ApplicationRecord
  belongs_to :user
  before_save :generate_access_token, :set_expiration

  scope :live, -> {where('expires_at > ?', Date.today)}

  def self.verify(access_token)
    api_key = self.live.find_by(access_token: access_token)
    if api_key
      return api_key
    else
      return ApiKey.none
    end
  end

  private

  def generate_access_token
  	self.access_token = SecureRandom.hex
  end

  def set_expiration
    self.expires_at = Date.today + 30
  end

end
