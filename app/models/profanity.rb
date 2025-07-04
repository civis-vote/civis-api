class Profanity < ApplicationRecord
  include SpotlightSearch
  include ImportProfanities
  include Paginator
  include CmAdmin::Profanity

  validates :profane_word, presence: true

  belongs_to :created_by, foreign_key: "created_by_id", class_name: "User"

  before_validation :set_created_by, on: :create

  delegate :full_name, to: :created_by, prefix: true, allow_nil: true

  scope :alphabetical, -> { order(profane_word: :asc) }

  scope :search_profane_word, lambda { |query = nil|
    return nil unless query

    where("profane_word ILIKE (?)", "%#{query}%")
  }

  scope :sort_records, lambda { |sort, sort_direction = "asc"|
    return nil if sort.blank?

    order("#{sort} #{sort_direction}")
  }

  scope :total_profanity_count, lambda {
    count
  }

  def format_for_csv(field_name)
    self[field_name.to_sym].present? ? self[field_name.to_sym] : "NA"
  end

  def self.import_profanities(file, user_id)
    import_fields_from_files(file, user_id)
  end

  private

  def set_created_by
    self.created_by = Current.user
  end
end
