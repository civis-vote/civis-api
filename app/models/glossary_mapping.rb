class GlossaryMapping < ApplicationRecord
    include SpotlightSearch
    include Paginator

      validates :consultation_id, presence: true
      validates :glossary_id, presence: true

    belongs_to :consultation
    belongs_to :wordindex, foreign_key: "glossary_id"
    
    
    scope :alphabetical, -> { order(consultation_id: :asc) }
    scope :search, lambda { |query|
      return nil  if query.blank?
      # terms = query.split(/\s+/)
      # terms = terms.map { |e|
      #   (e.gsub("*", "%").prepend("%") + "%").gsub(/%+/, "%")
      # }
      terms = query.to_s.split(/\s+/)
      num_or_conds = 2
      where(
        terms.map { |term|
          "(LOWER(consultation_id) LIKE ? OR LOWER(consultation_id) LIKE ?)"
  
        }.join(" OR "),
        *terms.map { |e| [e] * num_or_conds }.flatten,
      )
    }
    
  
    scope :sort_records, lambda { |sort, sort_direction = "asc"|
      return nil if sort.blank?
      order("#{sort} #{sort_direction}")
    }
end
