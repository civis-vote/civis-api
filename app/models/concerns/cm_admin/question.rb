module CmAdmin
  module Question
    extend ActiveSupport::Concern

    included do
      cm_admin do
        actions only: []
        set_icon 'far fa-newspaper'
        visible_on_sidebar false

        cm_index do
          page_title 'Questions'

          filter %i[question_text], :search, placeholder: 'Search'

          column :id
          column :question_text
          column :question_type, field_type: :enum
          column :created_at, field_type: :date, format: '%d %b, %Y'
        end

        cm_show page_title: :question_text do
          tab :profile, '' do
            cm_section 'Question details' do
              field :id, label: 'ID'
              field :question_text
              field :question_type, field_type: :enum
              field :is_optional, field_type: :custom, helper_method: :format_boolean_value
              field :supports_other, label: 'Other Option', field_type: :custom, helper_method: :format_boolean_value
              field :is_conditional, field_type: :custom, helper_method: :format_boolean_value
            end
            cm_section 'Options', display_if: ->(record) { record.display_options? } do
              nested_form_field :sub_questions do
                field :question_text
                field :question_text, field_type: :association, association_name: :conditional_question,
                                      association_type: 'belongs_to', label: 'Conditional Question'
              end
            end
            cm_section 'Log Details' do
              field :created_at, field_type: :date, format: '%d %b, %Y'
              field :updated_at, field_type: :date, format: '%d %b, %Y', label: 'Last Updated At'
            end
          end
        end

        cm_new page_title: 'Add Question', page_description: 'Enter all details to add Question' do
          cm_section 'Details' do
            form_field :question_text, input_type: :string
            form_field :question_text_hindi, input_type: :string
            form_field :question_text_odia, input_type: :string
            form_field :question_text_marathi, input_type: :string
            form_field :question_type, input_type: :single_select, is_required: true,
                                       html_attrs: { 'data-action': 'change->fields#hide',
                                                     'data-cm-hidden-id': 'supports_other options',
                                                     'data-cm-toggle-value': 'long_text' }
            form_field :is_optional, input_type: :switch
            form_field :is_conditional, input_type: :switch
            form_field :supports_other, input_type: :switch, html_attrs: { 'data-fields-target': 'cmHidden' }
          end
          cm_section 'Options', html_attrs: { 'data-fields-target': 'cmHidden', 'data-cm-id': 'options' } do
            nested_form_field :sub_questions do
              form_field :question_text, input_type: :string
              form_field :question_text_hindi, input_type: :string
              form_field :question_text_odia, input_type: :string
              form_field :question_text_marathi, input_type: :string
              form_field :conditional_question_id, input_type: :single_select, helper_method: :select_options_for_questions
            end
          end
        end

        cm_edit page_title: 'Edit Question', page_description: 'Enter all details to edit Question' do
          cm_section 'Details' do
            form_field :question_text, input_type: :string
            form_field :question_text_hindi, input_type: :string
            form_field :question_text_odia, input_type: :string
            form_field :question_text_marathi, input_type: :string
            form_field :question_type, input_type: :single_select, is_required: true,
                                       html_attrs: { 'data-action': 'change->fields#hide',
                                                     'data-cm-hidden-id': 'supports_other options',
                                                     'data-cm-toggle-value': 'long_text' }
            form_field :is_optional, input_type: :switch
            form_field :is_conditional, input_type: :switch
            form_field :supports_other, input_type: :switch, html_attrs: { 'data-fields-target': 'cmHidden' }
          end
          cm_section 'Options', html_attrs: { 'data-fields-target': 'cmHidden', 'data-cm-id': 'options' } do
            nested_form_field :sub_questions do
              form_field :question_text, input_type: :string
              form_field :question_text_hindi, input_type: :string
              form_field :question_text_odia, input_type: :string
              form_field :question_text_marathi, input_type: :string
              form_field :conditional_question_id, input_type: :single_select, helper_method: :select_options_for_questions
            end
          end
        end
      end
    end
  end
end
