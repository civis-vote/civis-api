class ConsultationSuggestionsService
  # Scoring weights — see "Consultation Suggestions" feature doc.
  SAME_THEME_SCORE = 3
  SHARED_AREA_OF_IMPACT_SCORE = 2
  SAME_DEPARTMENT_SCORE = 2
  FEATURED_SCORE = 1
  PREFERRED_THEME_SCORE = 2.5
  PREFERRED_AREA_OF_IMPACT_SCORE = 1.5
  HISTORY_THEME_SCORE = 1
  HISTORY_DEPARTMENT_SCORE = 0.5
  HISTORY_AREA_OF_IMPACT_SCORE = 0.5
  HISTORY_SCORE_CAP = 5

  attr_reader :user, :source

  def initialize(user:, consultation_id: nil)
    @user = user
    @source = ::Consultation.find_by(id: consultation_id) if consultation_id.present?
  end

  def call(limit: 3)
    candidates = candidate_pool.includes(:area_of_impacts).to_a
    return popular_consultations(candidates.map(&:id), limit) if candidates.empty?

    scored = candidates.map { |consultation| [consultation, score_for(consultation)] }
    if scored.all? { |(_consultation, score)| score.zero? }
      popular_consultations(candidates.map(&:id), limit)
    else
      scored.sort_by { |consultation, score| [-score, consultation.response_deadline] }
            .first(limit)
            .map(&:first)
    end
  end

  private

  def candidate_pool
    ::Consultation.published.public_consultation
                  .where('response_deadline > ?', Time.current)
                  .where.not(id: source&.id)
                  .where.not(id: user.responses.select(:consultation_id))
  end

  def score_for(consultation)
    content_score(consultation) + preference_score(consultation) + history_score(consultation)
  end

  def content_score(consultation)
    return 0 if source.nil?

    score = 0
    score += SAME_THEME_SCORE if source.theme_id.present? && consultation.theme_id == source.theme_id
    score += SHARED_AREA_OF_IMPACT_SCORE * (consultation.area_of_impact_ids & source.area_of_impact_ids).size
    score += SAME_DEPARTMENT_SCORE if consultation.department_id == source.department_id
    score += FEATURED_SCORE if consultation.is_featured
    score
  end

  def preference_score(consultation)
    score = 0
    score += PREFERRED_THEME_SCORE if consultation.theme_id.present? && preferred_theme_ids.include?(consultation.theme_id)
    score += PREFERRED_AREA_OF_IMPACT_SCORE * (consultation.area_of_impact_ids & preferred_area_of_impact_ids).size
    score
  end

  def history_score(consultation)
    theme_points = theme_response_counts[consultation.theme_id].to_i * HISTORY_THEME_SCORE
    department_points = department_response_counts[consultation.department_id].to_i * HISTORY_DEPARTMENT_SCORE
    area_of_impact_points = (consultation.area_of_impact_ids & area_of_impact_response_counts.keys).size * HISTORY_AREA_OF_IMPACT_SCORE

    [theme_points, HISTORY_SCORE_CAP].min +
      [department_points, HISTORY_SCORE_CAP].min +
      [area_of_impact_points, HISTORY_SCORE_CAP].min
  end

  def popular_consultation_ids(candidate_ids)
    shared = ::ConsultationResponse.visibilities[:shared]
    acceptable = ::ConsultationResponse.response_statuses[:acceptable]

    ::Consultation.where(id: candidate_ids)
                  .left_joins(:responses)
                  .group('consultations.id')
                  .order(
                    Arel.sql(
                      "COUNT(consultation_responses.id) FILTER (" \
                      "WHERE consultation_responses.visibility = #{shared} " \
                      "AND consultation_responses.response_status = #{acceptable}) DESC"
                    ),
                    'consultations.response_deadline ASC'
                  )
                  .pluck(:id)
  end

  def popular_consultations(candidate_ids, limit)
    ids = popular_consultation_ids(candidate_ids).first(limit)
    by_id = ::Consultation.where(id: ids).index_by(&:id)
    ids.filter_map { |id| by_id[id] }
  end

  def preferred_theme_ids
    @preferred_theme_ids ||= user.preferred_theme_ids
  end

  def preferred_area_of_impact_ids
    @preferred_area_of_impact_ids ||= user.area_of_impact_ids
  end

  def theme_response_counts
    @theme_response_counts ||= user.theme_response_counts
  end

  def department_response_counts
    @department_response_counts ||= user.department_response_counts
  end

  def area_of_impact_response_counts
    @area_of_impact_response_counts ||= user.area_of_impact_response_counts
  end
end
