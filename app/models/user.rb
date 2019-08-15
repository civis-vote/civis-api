class User < ApplicationRecord
  include Attachable
  include ImageResizer
  include SpotlightSearch
  include Scorable::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable, :lockable, :timeoutable, :trackable, :omniauthable

	belongs_to :city, class_name: 'Location', foreign_key: 'city_id', optional: true
	has_many :api_keys
  has_many :game_actions
  has_many :point_events

	validates :first_name, :last_name,  presence: true

  # enums
  enum role: { citizen: 0, admin: 1 }

  # callbacks
  after_commit :generate_api_key, :send_email_verification, on: :create

  # attachments
  has_one_attached :profile_picture

  # store accessors
  store_accessor :notification_settings, :notify_for_new_consultation

  scope :search_query, lambda { |query|
		return nil if query.blank?
		terms = query.downcase.split(/\s+/)
		terms = terms.map { |e|
			(e.gsub('*', '%').prepend('%') + '%').gsub(/%+/, '%')
		}
		num_or_conds = 1
		where(
			terms.map { |term|
				"(LOWER(users.first_name) LIKE ?)"
			}.join(' AND '),
			*terms.map { |e| [e] * num_or_conds }.flatten
		)
	}
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

  # Omnitauth related methods
  def self.create_from_facebook(info_hash, uid)
    if info_hash[:name].split.count > 1
      info_hash[:first_name] = info_hash[:name].split.first
      info_hash[:last_name] = info_hash[:name].split.last
    else
      info_hash[:first_name] = info_hash[:name]
    end
    User.add_fields_from_oauth(info_hash[:first_name], info_hash[:last_name], info_hash[:email], 'facebook', uid, info_hash[:image])
  end

  def self.create_from_google_oauth2(info_hash, uid)
    User.add_fields_from_oauth(info_hash[:first_name], info_hash[:last_name], info_hash[:email], 'google', uid, info_hash[:image])
  end

  def self.create_from_linkedin(info_hash, uid)
    User.add_fields_from_oauth(info_hash[:first_name], info_hash[:last_name], info_hash[:email], 'google', uid, info_hash[:picture_url])
  end

  def self.add_fields_from_oauth(f_name, l_name, email, provider, uid, image_url)
    user = User.new first_name: f_name, last_name: l_name, email: email, provider: provider, uid: uid, password: SecureRandom.hex(32)
    user.skip_confirmation_notification!
    user.save!
    UserProfilePictureUploadJob.perform_later(user, image_url) if image_url
    return user
  end
end
