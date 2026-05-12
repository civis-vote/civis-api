class Clause < ApplicationRecord
  has_paper_trail

  include Paginator
  include CmAdmin::Clause

  belongs_to :consultation
  belongs_to :clause_type, class_name: 'Constant', optional: true

  validates :clause_id, :clause_title, presence: true

  delegate :title, to: :consultation, prefix: true, allow_nil: true
  delegate :name, to: :clause_type, prefix: true, allow_nil: true
end
