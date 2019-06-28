class Location < ApplicationRecord
	has_many :children, class_name: 'Location', foreign_key: 'parent_id'
  belongs_to :parent, class_name: 'Location', optional: true

  enum location_type: [:city, :state]

  validates :name, :location_type,  presence: true

  scope :alphabetical, -> { order(name: :asc) }
  scope :cities, -> { where(location_type: :city) }
  scope :states, -> { where(location_type: :state) }

  scope :location_type_filter, lambda { |location_type|
    return all unless location_type.present?
    where(location_type: location_type)
  }

  scope :parent_filter, lambda { |parent_id|
    return all unless parent_id.present?
    where(parent_id: parent_id)
  }

  scope :search, lambda { |query|
      return nil  if query.blank?
    terms = query.downcase.split(/\s+/)
    # replace "*" with "%" for wildcard searches,
    # append '%', remove duplicate '%'s
    terms = terms.map { |e|
      (e.gsub('*', '%').prepend('%') + '%').gsub(/%+/, '%')
    }
    # configure number of OR conditions for provision
    # of interpolation arguments. Adjust this if you
    # change the number of OR conditions.
    num_or_conds = 1
    where(
      terms.map { |term|
        "(LOWER(name) LIKE ?)"
      }.join(' OR '),
      *terms.map { |e| [e] * num_or_conds }.flatten
    )
  }

end