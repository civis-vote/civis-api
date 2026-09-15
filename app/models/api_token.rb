class ApiToken < ApplicationRecord
  belongs_to :user

  enum :status, %i[live expired]
  enum :token_type, %i[access refresh pat]

  include CmAdmin::ApiToken

  validates :token, presence: true
  validates :token_type, presence: true

  before_validation :generate_token, on: :create

  delegate :full_name, to: :user, prefix: true

  private

  def generate_token
    self.token ||= SecureRandom.hex(32)
  end
end
