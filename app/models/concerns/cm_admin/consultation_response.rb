module CmAdmin
  module ConsultationResponse
    extend ActiveSupport::Concern

    included do
      cm_admin do
        actions only: %i[index show delete custom_action_modal export history]
        set_icon 'far fa-newspaper'
        set_policy_scopes [{ scope_name: 'organisation_only', display_name: 'Organisation Only' }]

        cm_index do
          page_title 'Consultation Responses'

          filter :theme_filter, :multi_select, helper_method: :select_options_for_theme, filter_with: :theme_filter, active_by_default: true
          filter :department_filter, :multi_select, helper_method: :select_options_for_department, filter_with: :department_filter, active_by_default: true
          filter :created_at, :date, placeholder: 'Created at'
          filter :updated_at, :date, placeholder: 'Updated at'

          importable class_name: 'ImportConsultationResponse', importer_type: 'custom_importer',
                     sample_file_path: '/csv_import_templates/consultation_response.csv'

          custom_action name: 'Approve', route_type: 'member', verb: 'patch', path: ':id/approve',
                        icon_name: 'fa-regular fa-circle-check', display_type: :button,
                        display_if: ->(obj) { obj.under_review? || obj.unacceptable? } do
            consultation_response = ::ConsultationResponse.find(params[:id])
            consultation_response.approve
            consultation_response
          end

          custom_action name: 'Reject', route_type: 'member', verb: 'patch', path: ':id/reject',
                        icon_name: 'fa-solid fa-ban', display_type: :button,
                        display_if: ->(obj) { obj.under_review? || obj.acceptable? } do
            consultation_response = ::ConsultationResponse.find(params[:id])
            consultation_response.reject
            consultation_response
          end

          column :id
          column :consultation_title
          column :user_response
          column :response_language, field_type: :enum, header: 'Language'
          column :user_full_name, header: 'Given by'
          column :response_status, header: 'Status', field_type: :enum
        end

        cm_show page_title: :id do
          tab :profile, '' do
            cm_show_section 'Consultation Response Details' do
              field :consultation_title
              field :user_response
              field :user_full_name, label: 'Given by'
              field :response_status, label: 'Status', field_type: :enum
            end
            cm_section 'Log Details' do
              field :created_at, field_type: :date, format: '%d %b, %Y'
              field :updated_at, field_type: :date, format: '%d %b, %Y', label: 'Last Updated At'
            end
          end
        end
      end
    end
  end
end
