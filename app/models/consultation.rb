class Consultation < ApplicationRecord
  acts_as_paranoid
  include SpotlightSearch
	include Paginator
  include Scorable::Consultation
  has_rich_text :summary
  include CmPageBuilder::Rails::HasCmContent
  has_rich_text :response_submission_message

  belongs_to :ministry
  belongs_to :created_by, foreign_key: "created_by_id", class_name: "User", optional: true
  belongs_to :organisation, optional: true
  has_many :responses, class_name: "ConsultationResponse"
  has_many :shared_responses, -> { shared }, class_name: "ConsultationResponse"
  has_many :anonymous_responses, -> { anonymous }, class_name: "ConsultationResponse"
  has_many :response_rounds
  has_one :consultation_hindi_summary, dependent: :destroy
  enum status: { submitted: 0, published: 1, rejected: 2, expired: 3 }
  enum review_type: { consultation: 0, policy: 1 }
  enum visibility: { public_consultation: 0, private_consultation: 1 }

  validates_presence_of :response_deadline

  after_commit :notify_admins, on: :create
  after_commit :create_response_round, on: :create
  after_commit :set_consultation_expiry_job, if: :saved_change_to_response_deadline?

  scope :status_filter, lambda { |status|
    return all unless status.present?
    where(status: status)
  }

  scope :ministry_filter, lambda { |ministry_id|
    return all unless ministry_id.present?
    where(ministry_id: ministry_id)
  }

  scope :category_filter, lambda { |category_id|
    return all unless category_id.present?
    joins(ministry: :category).
    where(categories: {id: category_id})
  }

  scope :featured_filter, lambda { |featured|
    return all unless featured.present?
    where(is_featured: featured)
  }

  scope :search_query, lambda { |query = nil|
    return nil unless query
    where("title ILIKE (?)", "%#{query}%")
  }

  scope :sort_records, lambda { |sort, sort_direction = "asc"|
    return nil if sort.blank?
    order("#{sort} #{sort_direction}")
  }

  scope :visibility_filter, lambda { |visibility|
    return all unless visibility.present?
    where(visibility: visibility)
  }

  def notify_admins
    self.response_token = SecureRandom.uuid unless self.response_token
    self.save!
    NotifyNewConsultationEmailToAdminJob.perform_later(self)
  end

  def publish
  	self.status = :published
  	self.published_at = DateTime.now unless self.published_at.present?
  	self.save!
    if self.consultation?
      NotifyNewConsultationEmailJob.perform_later(self) if self.public_consultation?
    else
      NotifyNewConsultationPolicyReviewEmailJob.perform_later(self)
    end
    NotifyPublishedConsultationEmailJob.perform_later(self) if self.created_by.citizen?
    if self.private_consultation?
      respondents = Respondent.where(response_round_id: self.response_round_ids)
      respondents.each do |respondent|
        url = Respondent.respondent_invite_url(self, respondent.user)
        InviteRespondentJob.perform_later(self, respondent.user, url)
      end
    end
  end

  def reject
  	self.update(status: :rejected)
  end

  def expire
    if responses.under_review.count == 0
  	  expired!
      NotifyExpiredConsultationEmailJob.perform_later(consultation_feedback_email, self, officer_name, officer_designation) if consultation_feedback_email
      if consultation?
        if ministry.poc_email_primary
          officer_name = ministry.primary_officer_name
          officer_designation = ministry.primary_officer_designation
          NotifyExpiredConsultationEmailJob.perform_later(ministry.poc_email_primary, self, officer_name, officer_designation)
        end
        if ministry.poc_email_secondary
          officer_name = ministry.secondary_officer_name
          officer_designation = ministry.secondary_officer_designation
          NotifyExpiredConsultationEmailJob.perform_later(ministry.poc_email_secondary, self, officer_name, officer_designation)
        end
      end
      UserUpVoteResponsesEmailJob.perform_later(self)
      UseResponseAsTemplateEmailJob.perform_later(self)
    else
      NotifyPendingReviewOfProfaneResponsesEmailToAdminJob.perform_later(self)
    end
  end

  def responded_on(user = Current.user)
    user_response = self.responses.find_by(user: user)
    return nil if user_response.nil?
    return user_response.created_at
  end

  def satisfaction_rating_distribution
    self.responses.group(:satisfaction_rating).count(:satisfaction_rating)
  end

  def featured
    self.update(is_featured: true)
  end

  def unfeatured
    self.update(is_featured: false)
  end

  def update_reading_time
    contents = self.page.components.map{|c| c["content"] }*" "
    total_word_count = contents.scan(/\w+/).size
    time = total_word_count.to_f / 200
    time_with_divmod = time.divmod 1
    array = [time_with_divmod[0].to_i, time_with_divmod[1].round(2) * 0.60 ]
    if array[1] > 0.30
      total_reading_time = array[0] + 1
    else
      total_reading_time = array[0]
    end
    self.reading_time = total_reading_time
    self.save
  end

  def days_left
    (response_deadline.to_date - Date.current).to_i if (response_deadline && published_at)
  end

  def feedback_url
    feedback_url = URI::HTTP.build(Rails.application.config.client_url.merge!({ path: "/consultations/" + "#{self.id}" +"/read", query: nil } ))
    feedback_url.to_s
  end

  def response_url
    response_url = URI::HTTP.build(Rails.application.config.client_url.merge!({ path: "/consultations/" + "#{self.id}" +"/summary", query: "response_token=#{self.response_token}" } ))
    response_url.to_s
  end

  def review_url
    response_url = URI::HTTP.build(Rails.application.config.client_url.merge!({ path: "/admin/consultations/" + "#{self.id}", query: nil } ))
    response_url.to_s
  end

  def create_response_round
    self.response_rounds.create()
  end

  def extend_deadline(deadline_date)
    self.response_deadline = deadline_date
    self.publish
  end

  def is_user_from_same_organisation?
   return true if self.organisation_id == Current.user.organisation_id
  end

  def english_summary_text
    return summary.to_plain_text if summary.to_plain_text.present?

    ActionView::Base.full_sanitizer.sanitize(page.components.map { |comp| comp['content'] if comp["componentType"] != "Upload" }.join(' '))
  end

  def set_consultation_expiry_job
    ConsultationExpiryJob.set(wait_until: TZInfo::Timezone.get("Asia/Kolkata").local_to_utc(Time.parse(self.response_deadline.to_datetime.to_s))).perform_later(self)
  end
end
