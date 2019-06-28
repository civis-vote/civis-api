class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable, :lockable, :timeoutable, :trackable, :omniauthable

	belongs_to :city, class_name: 'Location', foreign_key: 'city_id'
	has_many :api_keys

	validates :first_name, :last_name, :city_id,  presence: true

  # enums
  enum role: [:citizen, :admin]

  # callbacks
  after_commit :generate_api_key, :send_email_verification, on: :create

  store_accessor :notification_settings, :notify_for_new_consultation

  def find_or_generate_api_key
    self.live_api_key ? self.live_api_key : self.generate_api_key
  end

  def live_api_key
  	api_keys.live.last
  end

  def generate_api_key
  	api_keys.create
  end

  def confirmation_url
  	confirmation_url = URI::HTTP.build(Rails.application.config.client_url.merge!({path: '/confirm', query: "token=#{self.confirmation_token}"}))
  	confirmation_url.to_s
  end

  def send_email_verification
  	VerifyUserEmailJob.perform_later(self)
  end

  def update_last_activity
    update last_activity_at: Date.today
  end

  def was_active_today?
    last_activity_at.today?
  end
end