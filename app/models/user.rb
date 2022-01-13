class User < ApplicationRecord
  include Attachable
  include ImageResizer
  include SpotlightSearch
  include Paginator
  include Scorable::User
  include ImageUploader::Attachment(:profile_picture)
  attr_accessor :skip_invitation

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :confirmable,
         :recoverable, :rememberable, :validatable, :lockable, :timeoutable, :trackable, :omniauthable

	belongs_to :city, class_name: "Location", foreign_key: "city_id", optional: true
	has_many :api_keys, dependent: :destroy
  has_many :game_actions, dependent: :destroy
  has_many :point_events, dependent: :destroy
  has_many :responses, class_name: "ConsultationResponse"
  has_many :shared_responses, -> { shared }, class_name: "ConsultationResponse"
  has_many :votes, class_name: "ConsultationResponseVote"
  belongs_to :organisation, counter_cache: true, optional: true
  validates :first_name, presence: true
  validate :password_complexity

  # enums
  enum role: { citizen: 0, admin: 1, moderator: 2, organisation_employee: 3 }
  enum best_rank_type: { national: 0, state: 1, city: 2 }

  # callbacks
  after_commit :generate_api_key, :send_email_verification, on: :create

  # attachments
  # has_one_attached :profile_picture

  # store accessors
  store_accessor :notification_settings, :notify_for_new_consultation

  class << self
    def attachment_types
      ["profile_picture"]
    end
  end

  scope :search_query, lambda { |query|
		return nil if query.blank?
		terms = query.downcase.split(/\s+/)
		terms = terms.map { |e|
			(e.gsub("*", "%").prepend("%") + "%").gsub(/%+/, "%")
		}
		num_or_conds = 4
		where(
			terms.map { |term|
				"(LOWER(users.first_name) LIKE ? OR LOWER(users.last_name) LIKE ? OR LOWER(users.email) LIKE ? OR CAST(users.phone_number AS TEXT) LIKE ?)"
			}.join(" AND "),
			*terms.map { |e| [e] * num_or_conds }.flatten,
		)
	}

  scope :role_filter, lambda {|role|
    return nil unless role.present?
    where(role: role)
  }

  scope :location_filter, lambda {|location|
    return nil unless location.present?
    location_scope = [location]
    location_scope << Location.find(location).child_ids
    where(city_id: location_scope.flatten)
  }

  scope :sort_records, lambda { |sort = "created_at", sort_direction = "asc"|
    order("#{sort} #{sort_direction}, id asc")
  }

  scope :active, -> { where(active: true) }

  def self.notify_for_new_consultation_filter
    where("notification_settings->>'notify_for_new_consultation' = ?", "true")
  end

  def full_name
    "#{first_name}" + " #{last_name}"
  end

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
  	confirmation_url = URI::HTTPS.build(Rails.application.config.client_url.merge!({path: "/confirm", query: "token=#{self.confirmation_token}&callback_url=#{self.callback_url}"}))
  	confirmation_url.to_s
  end

  def send_email_verification
  	VerifyUserEmailJob.perform_later(self) unless confirmed_at
    if (!confirmed_at && referring_consultation_id)
      VerifyUserEmailAfter8HoursJob.set(wait: 8.hours).perform_later(self.id, self.referring_consultation_id) 
      VerifyUserEmailAfter72HoursJob.set(wait: 80.hours).perform_later(self.id)
      VerifyUserEmailAfter120HoursJob.set(wait: 200.hours).perform_later(self.id)
    end
  end

  def update_last_activity
    update last_activity_at: Date.today
  end

  def was_active_today?
    last_activity_at.today?
  end

  def format_for_csv(field_name)
    self[field_name.to_sym].present? ? self[field_name.to_sym] : "NA"
  end

  # Omnitauth related methods
  def self.create_from_facebook(info_hash, uid)
    if info_hash[:name].split.count > 1
      info_hash[:first_name] = info_hash[:name].split.first
      info_hash[:last_name] = info_hash[:name].split.last
    else
      info_hash[:first_name] = info_hash[:name]
    end
    ::User.add_fields_from_oauth(info_hash[:first_name], info_hash[:last_name], info_hash[:email], "facebook", uid, info_hash[:image])
  end

  def self.create_from_google_oauth2(info_hash, uid)
    ::User.add_fields_from_oauth(info_hash[:first_name], info_hash[:last_name], info_hash[:email], "google", uid, info_hash[:image])
  end

  def self.create_from_linkedin(info_hash, uid)
    ::User.add_fields_from_oauth(info_hash[:first_name], info_hash[:last_name], info_hash[:email], "google", uid, info_hash[:picture_url])
  end

  def self.add_fields_from_oauth(f_name, l_name, email, provider, uid, image_url)
    user = ::User.new first_name: f_name, last_name: l_name, email: email, provider: provider, uid: uid, password: SecureRandom.hex(32), confirmed_at: DateTime.now
    user.skip_confirmation_notification!
    user.save!
    UserProfilePictureUploadJob.perform_later(user, image_url) if image_url
    return user
  end

  def forgot_password_url(raw_token)
    forgot_password_url = URI::HTTPS.build(Rails.application.config.client_url.merge!({ path: "/auth/forgot-password", query: "reset_password_token=#{raw_token}"} ))
    forgot_password_url.to_s
  end

  def unsubscribe_url
    unsubscribe_url = URI::HTTPS.build(Rails.application.config.client_url.merge!({path: "/emails/unsubscribe", query: "unsubscribe_token=#{self.uuid}"}))
    unsubscribe_url.to_s
  end

  def self.invite_employee(params, current_user)
    emails = params[:email].split(",")
    emails.each do |email|
      user = ::User.invite!({ email: email, organisation_id: params[:organisation_id] ,skip_invitation: true, invitation_sent_at: DateTime.now, confirmed_at: DateTime.now, role: "organisation_employee", active: params[:active] }, current_user)
      raw_token = user.raw_invitation_token
      user_record = ::User.find_by(email: email.strip)
      unless user_record.active?
        organisation = ::Organisation.find(params[:organisation_id].to_i)
        ::Organisation.increment_counter(:users_count, organisation.id)
      end
      if Rails.env.development?
        url = URI::HTTP.build(Rails.application.config.host_url.merge!({path: "/users/edit_invite", query: "invitation_token=#{raw_token}"})).to_s
      else
        url = URI::HTTPS.build(Rails.application.config.host_url.merge!({path: "/users/edit_invite", query: "invitation_token=#{raw_token}"})).to_s
      end
      InviteOrganisationEmployeeJob.perform_later(user_record, url)
    end 
  end

  def picture_url
    if self.profile_picture.present?
      self.profile_picture_url  
    else
      "media/application/images/defalut-user.svg"
    end
  end

  def deactivate(organisation_id)
    self.active = false
    self.save(validate: false)
    Organisation.decrement_counter(:users_count, organisation_id)
  end

  def password_complexity
    if password.present? && !password.match(/^(?=.*[A-Za-z])(?=.*\d)(?=.*[$@$!%*#?&]).{8,}$/)
      errors.add :password, "Password length min 8 charcter and include at least one alphabet, one special character, and one digit"
    end
  end
end
