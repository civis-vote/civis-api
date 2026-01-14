module CmAdmin
  module CustomHelper
    ::CONSTANT_TYPES.each do |constant_type|
      define_method "select_options_for_#{constant_type}" do |_ = nil, _ = nil|
        ::Constant.where(constant_type: constant_type).pluck(:name, :id)
      end
    end

    def select_options_for_cm_role(_ = nil, _ = nil)
      ::CmRole.pluck(:name, :id)
    end

    def select_options_for_user(_ = nil, _ = nil)
      ::User.active.all.map { |user| [user.full_name, user.id] }
    end

    def select_options_for_admin_panel_user(_ = nil, _ = nil)
      ::User.active.joins(:cm_role).where.not(cm_role: { name: 'Citizen' }).map { |user| [user.full_name, user.id] }
    end

    def select_options_for_theme(_ = nil, _ = nil)
      ::Theme.pluck(:name, :id)
    end

    def select_options_for_location(_ = nil, _ = nil)
      ::Location.pluck(:name, :id)
    end

    def select_options_for_city(_ = nil, _ = nil)
      ::Location.city.pluck(:name, :id)
    end

    def select_options_for_state(_ = nil, _ = nil)
      ::Location.state.pluck(:name, :id)
    end

    def format_boolean_value(record, field_name)
      value = record.send(field_name)
      value.present? ? 'Yes' : 'No'
    end

    def select_options_for_wordindex(_ = nil, _ = nil)
      ::Wordindex.pluck(:word, :id)
    end

    def select_options_for_consultation(_ = nil, _ = nil)
      ::Consultation.pluck(:title, :id)
    end

    def select_options_for_department(_ = nil, _ = nil)
      ::Department.pluck(:name, :id)
    end

    def select_options_for_assignable_cm_role(_ = nil, _ = nil)
      ::CmRole.pluck(:name, :id)
    end

    def select_options_for_organisation_engagement_type(_ = nil, _ = nil)
      ::Organisation.engagement_types.keys.map { |et| [et, et] }
    end

    def select_options_for_questions(_ = nil, _ = nil)
      ::Question.main_questions.pluck(:question_text, :id)
    end

    def selected_conditional_option(record, _)
      [[record&.conditional_question&.question_text, record&.conditional_question&.id]]
    end

    def select_options_for_boolean(_ = nil, _ = nil)
      [['Yes', true], ['No', false]]
    end

  end
end
