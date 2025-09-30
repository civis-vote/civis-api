class DepartmentContact < ApplicationRecord
  belongs_to :department

  enum contact_type: { primary: 0, secondary: 1, other: 3 }

  validates :contact_type, :email, presence: true

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: 'is invalid' }
end
