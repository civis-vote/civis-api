class Profanity < ApplicationRecord
    include SpotlightSearch
    include ImportProfanities
    include Paginator
  
      validates :profane_word,  presence: true
  
    belongs_to :created_by, foreign_key: "created_by_id", class_name: "User"
  
    scope :alphabetical, -> { order(profane_word: :asc) }
    
    scope :search_profane_word, lambda { |query = nil|
      return nil unless query
      where("profane_word ILIKE (?)", "%#{query}%")
    }

    scope :sort_records, lambda { |sort, sort_direction = "asc"|
      return nil if sort.blank?
      order("#{sort} #{sort_direction}")
    }

    def format_for_csv(field_name)
      self[field_name.to_sym].present? ? self[field_name.to_sym] : "NA"
    end
    
    def self.import_profanities(file,user_id)
      self.import_fields_from_files(file,user_id)
    end
end
