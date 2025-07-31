module CmAdmin
  module ResponseRound
    extend ActiveSupport::Concern

    included do
      cm_admin do
        actions only: %i[index show delete custom_action_modal export history]
        set_icon 'far fa-newspaper'
        visible_on_sidebar false

        cm_index do
          page_title 'Response Rounds'

          filter %i[id], :search, placeholder: 'Search'

          column :id
          column :created_at, field_type: :date, format: '%d %b, %Y'
        end

        cm_show page_title: :id do
          tab :profile, '' do
            cm_section 'Response Round details' do
              field :id, label: 'ID'
              field :created_at, field_type: :date, format: '%d %b, %Y'
            end
            cm_section 'Log Details' do
              field :created_at, field_type: :date, format: '%d %b, %Y'
              field :updated_at, field_type: :date, format: '%d %b, %Y', label: 'Last Updated At'
            end
          end

          tab :questions, 'questions', associated_model: 'questions', layout_type: 'cm_association_index' do
            column :id
            column :question_text
            column :question_type, field_type: :enum
            column :is_optional, field_type: :custom, helper_method: :format_boolean_value
          end
        end
      end
    end
  end
end
