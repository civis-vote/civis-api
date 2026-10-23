class AccountDeletionService
  CREATOR_REFERENCE_MODELS = %w[
    Consultation Department Organisation CaseStudy Profanity Wordindex ShowcaseSlide
    CmPrompt CmSupportTicket CmPlatformSetting
  ].freeze

  def initialize(user)
    @user = user
  end

  attr_reader :user

  def call
    raise ArgumentError, "User is required" unless user

    city = user.city
    state = city&.parent

    ApplicationRecord.transaction do
      delete_consultation_responses
      delete_votes_on_other_responses
      delete_points_and_ranks
      delete_misc_data
      nullify_creator_references
      purge_profile_picture
      user.destroy!

      recompute_ranks(city, state)
    end
    true
  rescue StandardError => e
    Airbrake.notify(e)
    raise
  end

  private

  def delete_consultation_responses
    respondent_ids = Respondent.where(user_id: user.id).pluck(:id)
    response_ids = ConsultationResponse.unscoped.where(user_id: user.id).pluck(:id)
    response_ids += ConsultationResponse.unscoped.where(respondent_id: respondent_ids).pluck(:id) if respondent_ids.any?
    response_ids.uniq!
    return if response_ids.empty?

    ConsultationResponse.unscoped.where(template_id: response_ids).update_all(template_id: nil)
    ConsultationResponseVote.where(consultation_response_id: response_ids).delete_all
    ActiveStorage::Attachment.where(record_type: "ConsultationResponse", record_id: response_ids).each(&:purge)

    # Paranoia's destroy only soft-deletes; really_destroy! hard-deletes and runs the destroy callbacks.
    ConsultationResponse.unscoped.where(id: response_ids).each(&:really_destroy!)
  end

  def delete_votes_on_other_responses
    # Votes on soft-deleted responses are removed without callbacks - the counter
    # refresh in after_commit would hit a nil association and abort the deletion.
    live_ids = ConsultationResponse.where(id: user.votes.select(:consultation_response_id)).pluck(:id)
    ConsultationResponseVote.where(user_id: user.id).where.not(consultation_response_id: live_ids).delete_all
    ConsultationResponseVote.where(user_id: user.id, consultation_response_id: live_ids).each(&:destroy)
  end

  def delete_points_and_ranks
    GameAction.where(user_id: user.id).delete_all
    PointEvent.where(user_id: user.id).delete_all
  end

  def delete_misc_data
    NotificationSetting.where(user_id: user.id).delete_all
    Respondent.where(user_id: user.id).delete_all
    UserCount.where(user_id: user.id).delete_all
    CtPageView.where(owner: user).delete_all if defined?(::CtPageView)
    User.where(invited_by_type: 'User', invited_by_id: user.id).update_all(invited_by_id: nil, invited_by_type: nil)
  end

  def nullify_creator_references
    CREATOR_REFERENCE_MODELS.each do |model_name|
      model = model_name.safe_constantize
      next unless model

      nullify_creator_columns(model)
    end
  end

  def nullify_creator_columns(model)
    columns = model.column_names
    updates = {}
    updates[:created_by_id] = nil if columns.include?("created_by_id")
    updates[:created_by_type] = nil if columns.include?("created_by_type")
    updates[:updated_by_id] = nil if columns.include?("updated_by_id")
    updates[:updated_by_type] = nil if columns.include?("updated_by_type")
    return if updates.empty?

    conditions = creator_reference_conditions(columns)
    return if conditions.empty?

    model.unscoped.where(conditions.join(" OR "), id: user.id).update_all(updates)
  end

  def creator_reference_conditions(columns)
    conditions = []
    if columns.include?("created_by_id")
      conditions << if columns.include?("created_by_type")
                      "(created_by_type = 'User' AND created_by_id = :id)"
                    else
                      "(created_by_id = :id)"
                    end
    end
    if columns.include?("updated_by_id")
      conditions << if columns.include?("updated_by_type")
                      "(updated_by_type = 'User' AND updated_by_id = :id)"
                    else
                      "(updated_by_id = :id)"
                    end
    end
    conditions
  end

  def purge_profile_picture
    user.profile_picture.purge if user.profile_picture.attached?
  end

  def recompute_ranks(city, state)
    # NOTE: these are defined as singleton methods on Scorable::User, not on the
    # User class itself (inside the concern, `User.update_national_rank` resolves
    # to the module due to lexical constant lookup).
    Scorable::User.update_national_rank
    Scorable::User.update_state_rank(state) if state
    Scorable::User.update_city_rank(city) if city
  end
end
