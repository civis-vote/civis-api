class ApiToken < ApplicationRecord
  belongs_to :user

  enum :token_type, %i[access refresh pat]

  include CmAdmin::ApiToken

  scope :user_only, -> { where(user_id: Current.user&.id) }
  scope :live, -> { where(expires_at: [nil, Time.current..]) }
  scope :expired, -> { where(expires_at: ...Time.current) }

  validates :token, presence: true
  validates :token_type, presence: true
  validates :name, presence: true
  validates :name, length: { maximum: 100 }

  before_validation :generate_token, on: :create

  delegate :full_name, to: :user, prefix: true

  def token_type_display
    pat? ? "PAT" : token_type.to_s.titleize
  end

  def cm_display_name
    "[#{id}] #{name}"
  end

  def live?
    expires_at.nil? || expires_at.future?
  end

  def expired?
    !live?
  end

  def status
    live? ? "live" : "expired"
  end

  private

  def generate_token
    self.token ||= SecureRandom.hex(32)
  end
end
