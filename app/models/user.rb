class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :lockable, :timeoutable, :trackable, :omniauthable

	belongs_to :city, class_name: 'Location', foreign_key: 'city_id'
	has_many :api_keys

	validates :first_name, :last_name, :city_id,  presence: true

  # callbacks
  before_create :generate_confirmation_token
  after_commit :generate_api_key, :send_email_verification, on: :create

  def find_or_generate_api_key
    self.live_api_key ? self.live_api_key : self.generate_api_key
  end

  def live_api_key
  	api_keys.live.last
  end

  def generate_api_key
  	api_keys.create
  end

  def generate_confirmation_token
  	self.confirmation_token = SecureRandom.uuid
  end

  def confirmation_url
  	confirmation_url = URI::HTTP.build(Rails.application.config.client_url.merge!({path: '/confirm', query: "token=#{confirmation_token}"}))
  	confirmation_url.to_s
  end

  def send_email_verification
  	VerifyUserEmailJob.perform_later(self)
  end
end