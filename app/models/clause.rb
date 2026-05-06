class Clause < ApplicationRecord
  has_paper_trail

  include Paginator
  include CmAdmin::Clause

  belongs_to :consultation
  belongs_to :clause_type, class_name: 'Constant', optional: true

  validates :clause_id, :clause_title, presence: true

  delegate :title, to: :consultation, prefix: true, allow_nil: true

  def clause_type_names
    clause_type&.name
  end
end
