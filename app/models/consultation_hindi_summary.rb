class ConsultationHindiSummary < ApplicationRecord
	include CmPageBuilder::Rails::HasCmContent
	belongs_to :consultation
	validates_uniqueness_of :consultation_id
end
