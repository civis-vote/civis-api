module CmAdmin
  module Question
    extend ActiveSupport::Concern

    included do
      cm_admin do
        actions only: []
        set_icon 'far fa-newspaper'
        visible_on_sidebar false
        permit_additional_fields [{ sub_questions_attributes: %i[id question_text question_text_hindi question_text_odia _destroy
                                                                 question_text_marathi position conditional_question_id] }]

        cm_index do
          page_title 'Questions'

          sortable_columns [{ column: 'position', display_name: 'Position', default: true, default_direction: 'asc' },
                            { column: 'created_at', display_name: 'Created At' },
                            { column: 'updated_at', display_name: 'Updated At' }]

          filter %i[question_text], :search, placeholder: 'Search'
          filter :is_optional, :single_select, helper_method: :select_options_for_boolean
          filter :conditional_question, :single_select, helper_method: :select_options_for_boolean,
                                                        filter_with: :is_conditional_questions

          custom_action name: 'response_round_questions', route_type: 'collection', verb: 'get',
                        path: '/response_round_questions', display_type: :route do
            response_round_id = if params[:question_id].present?
                                  ::Question.find(params[:question_id]).response_round_id
                                elsif params[:response_round_id].present?
                                  params[:response_round_id]
                                end
            @questions = ::Question.main_questions.where(response_round_id:).search_filter(params[:search])
            @questions = @questions.where.not(id: params[:question_id]) if params[:question_id].present?
            {
              "results": @questions.map { |question| { "id": question.id, "text": question.question_text } },
              "pagination": { "more": false }
            }
          end

          column :position
          column :question_text
          column :is_optional, field_type: :custom, helper_method: :format_boolean_value, header: 'Optional?'
          column :question_type, field_type: :enum
          column :conditional_question?, field_type: :custom, helper_method: :format_boolean_value
        end

        cm_show page_title: :question_text do
          tab :profile, '' do
            cm_section 'Question details' do
              field :id, label: 'ID'
              field :question_text
              field :question_type, field_type: :enum
              field :is_optional, field_type: :custom, helper_method: :format_boolean_value, label: 'Optional?'
              field :position
              field :supports_other, label: 'Other Option', field_type: :custom, helper_method: :format_boolean_value
            end
            cm_section 'Options', display_if: ->(record) { record.display_options? } do
              nested_form_field :sub_questions do
                field :question_text
                field :question_text_hindi
                field :question_text_odia
                field :question_text_marathi
                field :question_text, field_type: :association, association_name: 'conditional_question',
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
            form_field :question_type, input_type: :single_select, is_required: true
            form_field :is_optional, input_type: :switch, label: 'Optional?'
            form_field :supports_other, input_type: :switch, label: 'Supports Other?'
            nested_form_section 'Options', html_attrs: { 'data-section-id': 'options' } do
              nested_form_field :sub_questions, is_positionable: ->(_) { true } do
                form_field :question_text, input_type: :string
                form_field :question_text_hindi, input_type: :string
                form_field :question_text_odia, input_type: :string
                form_field :question_text_marathi, input_type: :string
                form_field :conditional_question_id, input_type: :single_select
              end
            end
          end
        end

        cm_edit page_title: 'Edit Question', page_description: 'Enter all details to edit Question' do
          cm_section 'Question details' do
            form_field :question_text, input_type: :string
            form_field :question_text_hindi, input_type: :string
            form_field :question_text_odia, input_type: :string
            form_field :question_text_marathi, input_type: :string
            form_field :question_type, input_type: :single_select, is_required: true
            form_field :position, input_type: :integer
            form_field :is_optional, input_type: :switch, label: 'Optional?'
            form_field :supports_other, input_type: :switch, label: 'Supports Other?'
            nested_form_section 'Options', html_attrs: { 'data-section-id': 'options' } do
              nested_form_field :sub_questions, is_positionable: ->(_) { true } do
                form_field :question_text, input_type: :string
                form_field :question_text_hindi, input_type: :string
                form_field :question_text_odia, input_type: :string
                form_field :question_text_marathi, input_type: :string
                form_field :conditional_question_id, input_type: :single_select, helper_method: :selected_conditional_option
              end
            end
          end
        end
      end
    end
  end
end
