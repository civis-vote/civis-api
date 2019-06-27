class Ministry < ApplicationRecord
	include Attachable
	include ImageResizer

	validates :name, :level,  presence: true

	# enums
  enum level: [:national, :state, :local]

  belongs_to :created_by, foreign_key: 'created_by_id', class_name: 'User'
  has_one_attached :logo
  has_one_attached :cover_photo


  class << self 

    def attachment_types
      ['logo', 'cover_photo']
    end

  end

  scope :approved, -> { where(is_approved: true) }
  scope :alphabetical, -> { order(name: :asc) }

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