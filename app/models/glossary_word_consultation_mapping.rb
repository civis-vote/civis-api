class GlossaryWordConsultationMapping < ApplicationRecord
  include CmAdmin::GlossaryWordConsultationMapping

  validates :consultation_id, presence: true
  validates :glossary_id, presence: true

  belongs_to :consultation
  belongs_to :glossary, class_name: 'Wordindex', foreign_key: 'glossary_id'

  delegate :title, to: :consultation, prefix: true, allow_nil: true
  delegate :word, to: :glossary, prefix: true, allow_nil: true

  scope :order_by_id, -> { order(consultation_id: :asc) }
  scope :search, lambda { |query|
    return nil if query.blank?

    terms = query.to_s.split(/\s+/)
    num_or_conds = 2
    where(
      terms.map do |_term|
        "(LOWER(consultation_id) LIKE ?)"
      end.join(" OR "),
      *terms.map { |e| [e] * num_or_conds }.flatten
    )
  }

  scope :sort_records, lambda { |sort, sort_direction = "asc"|
    return nil if sort.blank?

    order("#{sort} #{sort_direction}")
  }
end
