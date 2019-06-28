class Consultation < ApplicationRecord
  belongs_to :ministry
  belongs_to :created_by, foreign_key: 'created_by_id', class_name: 'User', optional: true

  enum status: [:submitted, :publised, :rejected, :expired]

end