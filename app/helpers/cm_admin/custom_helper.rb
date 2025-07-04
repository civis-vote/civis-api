module CmAdmin
  module CustomHelper
    def select_options_for_cm_role(_ = nil, _ = nil)
      ::CmRole.pluck(:name, :id)
    end

    def select_options_for_user(_ = nil, _ = nil)
      ::User.active.all.map { |user| [user.full_name, user.id] }
    end

    def select_options_for_category(_ = nil, _ = nil)
      ::Category.pluck(:name, :id)
    end

    def select_options_for_location(_ = nil, _ = nil)
      ::Location.pluck(:name, :id)
    end

    def format_boolean_value(record, field_name)
      value = record.send(field_name)
      value.present? ? 'Yes' : 'No'
    end

    def select_options_for_consultation_response_status(_ = nil, _ = nil)
      ::ConsultationResponse.response_statuses.keys.map { |status| [status.titleize, status] }
    end

    def select_options_for_wordindex(_ = nil, _ = nil)
      ::Wordindex.pluck(:word, :id)
    end

    def select_options_for_consultation(_ = nil, _ = nil)
      ::Consultation.pluck(:title, :id)
    end

    def select_options_for_consultation_status(_ = nil, _ = nil)
      ::Consultation.statuses.keys.map { |status| [status.titleize, status] }
    end

    def select_options_for_consultation_review_type(_ = nil, _ = nil)
      ::Consultation.review_types.keys.map { |status| [status.titleize, status] }
    end

    def select_options_for_consultation_visibility(_ = nil, _ = nil)
      ::Consultation.visibilities.keys.map { |status| [status.titleize, status] }
    end

    def select_options_for_ministry(_ = nil, _ = nil)
      ::Ministry.pluck(:name, :id)
    end

    def select_options_for_assignable_cm_role(_ = nil, _ = nil)
      ::CmRole.where.not(name: 'Organisation Employee').pluck(:name, :id)
    end
  end
end
