class ConsultationHindiSummary < ApplicationRecord
	belongs_to :consultation
	validates_uniqueness_of :consultation_id
end
