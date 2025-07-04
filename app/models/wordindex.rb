class Wordindex < ApplicationRecord
  include SpotlightSearch
  include ImportGlossary
  include CmAdmin::Wordindex

  validates :word, presence: true

  has_many :glossary_word_consultation_mappings, dependent: :destroy, foreign_key: 'glossary_id'

  belongs_to :created_by, foreign_key: "created_by_id", class_name: "User"

  delegate :full_name, to: :created_by, prefix: true, allow_nil: true

  before_validation :set_created_by, on: :create

  scope :alphabetical, -> { order(word: :asc) }
  scope :search, lambda { |query|
    return nil if query.blank?

    terms = query.downcase.split(/\s+/)
    # replace "*" with "%" for wildcard searches,
    # append '%', remove duplicate '%'s
    terms = terms.map do |e|
      (e.gsub("*", "%").prepend("%") + "%").gsub(/%+/, "%")
    end
    # configure number of OR conditions for provision
    # of interpolation arguments. Adjust this if you
    # change the number of OR conditions.
    num_or_conds = 2
    where(
      terms.map do |_term|
        "(LOWER(word) LIKE ? OR LOWER(description) LIKE ?)"
      end.join(" OR "),
      *terms.map { |e| [e] * num_or_conds }.flatten
    )
  }

  scope :search_word, lambda { |query|
    return nil if query.blank?

    terms = query.downcase.split(/\s+/)
    terms = terms.map do |e|
      (e.gsub("*", "%").prepend("%") + "%").gsub(/%+/, "%")
    end
    num_or_conds = 2
    where(
      terms.map do |_term|
        "(LOWER(word) = LOWER(?) OR word = ? )"
      end.join(" OR "),
      *terms.map { |e| [e] * num_or_conds }.flatten
    )
  }

  scope :sort_records, lambda { |sort, sort_direction = "asc"|
    return nil if sort.blank?

    order("#{sort} #{sort_direction}")
  }

  def format_for_csv(field_name)
    self[field_name.to_sym].present? ? self[field_name.to_sym] : "NA"
  end

  def self.import_glossary(file, user_id)
    import_fields_from_files(file, user_id)
  end

  private

  def set_created_by
    self.created_by = Current.user
  end
end
