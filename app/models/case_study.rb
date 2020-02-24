class CaseStudy < ApplicationRecord
  include SpotlightSearch
  include Paginator

	validates :name,  presence: true

  belongs_to :created_by, foreign_key: "created_by_id", class_name: "User"

  scope :search, lambda { |query|
    return nil  if query.blank?
    terms = query.downcase.split(/\s+/)
    # replace "*" with "%" for wildcard searches,
    # append '%', remove duplicate '%'s
    terms = terms.map { |e|
      (e.gsub("*", "%").prepend("%") + "%").gsub(/%+/, "%")
    }
    # configure number of OR conditions for provision
    # of interpolation arguments. Adjust this if you
    # change the number of OR conditions.
    num_or_conds = 2
    where(
      terms.map { |term|
        "(LOWER(name) LIKE ? OR LOWER(ministry_name) LIKE ?)"

      }.join(" OR "),
      *terms.map { |e| [e] * num_or_conds }.flatten,
    )
  }

  scope :sort_records, lambda { |sort, sort_direction = "asc"|
    return nil if sort.blank?
    order("#{sort} #{sort_direction}")
  }

end
