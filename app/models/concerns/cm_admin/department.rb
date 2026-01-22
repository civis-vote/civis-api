module CmAdmin
  module Department
    extend ActiveSupport::Concern

    STATUS_TAG_COLORS = { approved: 'bg-success', not_approved: 'bg-danger' }.freeze

    included do
      cm_admin do
        actions only: []
        set_icon 'fas fa-suitcase'
        permit_additional_fields [segment_ids: []]
        sortable_columns [
          { column: 'created_at', display_name: 'Created At', default: true, default_direction: 'desc' },
          { column: 'updated_at', display_name: 'Updated At' },
          { column: 'consultations_consultation_responses_count', display_name: 'Response Count' }
        ]

        cm_index do
          page_title 'Departments'

          filter %i[name], :search, placeholder: 'Search'
          filter :status, :single_select, collection: [%w[Approved true], ['Not Approved', false]], filter_with: :status_filter
          filter :name, :multi_select, helper_method: :select_options_for_department, filter_with: :name_filter, active_by_default: true
          filter :level, :multi_select, active_by_default: true
          filter :location_id, :multi_select, helper_method: :select_options_for_location, active_by_default: true

          custom_action name: 'Approve', route_type: 'member', verb: 'patch', path: ':id/approve',
                        icon_name: 'fa-regular fa-circle-check', display_type: :button,
                        display_if: ->(obj) { obj.status == 'not_approved' } do
            department = ::Department.find(params[:id])
            department.approve
            department
          end

          custom_action name: 'Reject', route_type: 'member', verb: 'patch', path: ':id/reject',
                        icon_name: 'fa-solid fa-ban', display_type: :button,
                        display_if: ->(obj) { obj.status == 'approved' } do
            department = ::Department.find(params[:id])
            department.reject
            department
          end

          column :name
          column :created_by_full_name, header: 'Created By'
          column :status, field_type: :tag, tag_class: STATUS_TAG_COLORS
          column :location_name, header: 'Location'
        end

        cm_show page_title: :name do
          bulk_action name: 'delete', display_name: 'Delete', icon_name: 'fa-solid fa-square-xmark', display_type: :modal,
                      success_message: ->(success) { "Successfully Deleted #{success.size} Departments." },
                      error_message: lambda { |errors|
                        "<p class='mb-0'>Failed to delete #{errors.size} Departments.</p>
                        <ul>
                          #{errors.map do |error|
                            "<li><a href='/cm_admin/departments/#{error.failed_id}' target='_blank'>#{error.row_identifier}</a> #{error.error_message}</li>"
                          end.join}
                        </ul>"
                      },
                      modal_configuration: { title: 'Delete', description: 'Are you sure you want to Delete selected Departments.',
                                             confirmation_text: 'Confirm' } do |id|
            ::Department.find(id).destroy
          end

          bulk_action name: 'duplicate', display_name: 'Duplicate', icon_name: 'fa-solid fa-clone', display_type: :modal,
                      success_message: ->(success) { "Successfully duplicated #{success.size} Departments." },
                      error_message: lambda { |errors|
                        "<p class='mb-0'>Failed to duplicate #{errors.size} Departments.</p>
                        <ul>
                          #{errors.map do |error|
                            "<li><a href='/cm_admin/departments/#{error.failed_id}' target='_blank'>#{error.row_identifier}</a> #{error.error_message}</li>"
                          end.join}
                        </ul>"
                      },
                      modal_configuration: { title: 'Duplicate Department', description: 'Are you sure you want to Duplicate selected Departments',
                                             confirmation_text: 'Confirm' } do |id|
            @department = ::Department.find(id)
            @department.duplicate
            @department
          end

          tab :profile, '' do
            cm_section 'Department details' do
              field :name
              field :logo, field_type: :image
              field :name_hindi, label: 'Name in Hindi'
              field :name_odia, label: 'Name in Odia'
              field :name_marathi, label: 'Name in Marathi'
              field :level, field_type: :enum
              field :status, field_type: :tag, tag_class: STATUS_TAG_COLORS
              field :location_name, label: 'Location'
              field :segment_names, label: 'Segments'
              field :created_by_full_name, label: 'Created By'
              nested_form_field :department_contacts, label: 'Contacts' do
                field :contact_type, field_type: :enum
                field :email
                field :name
                field :designation
              end
            end
            cm_section 'Log Details' do
              field :created_at, field_type: :date, format: '%d %b, %Y'
              field :updated_at, field_type: :date, format: '%d %b, %Y', label: 'Last Updated At'
            end
          end
          tab :consultations, 'consultations', associated_model: :consultations, layout_type: 'cm_association_index' do
            column :title
            column :status, field_type: :tag, tag_class: CmAdmin::Consultation::STATUS_TAG_COLORS
            column :response_deadline, field_type: :date, format: '%d %b, %Y'
            column :created_by_full_name, header: 'Created By'
          end
        end

        cm_new page_title: 'Add Department', page_description: 'Enter all details to add Department' do
          cm_section 'Details' do
            form_field :name, input_type: :string
            form_field :logo, input_type: :single_file_upload
            alert_box type: :info, body: 'Only JPEG and PNG files are supported for Logo'
            form_field :name_hindi, input_type: :string, label: 'Name in Hindi'
            form_field :name_odia, input_type: :string, label: 'Name in Odia'
            form_field :name_marathi, input_type: :string, label: 'Name in Marathi'
            form_field :level, input_type: :single_select
            form_field :location_id, input_type: :single_select, helper_method: :select_options_for_location
            form_field :segment_ids, input_type: :multi_select, helper_method: :select_options_for_segment,
                                     display_if: ->(_) { Current.user&.role?('super_admin') }, label: 'Segments'
            nested_form_field :department_contacts, label: 'Contacts' do
              form_field :contact_type, input_type: :single_select
              form_field :email
              form_field :name
              form_field :designation
            end
          end
        end

        cm_edit page_title: 'Edit Department', page_description: 'Enter all details to edit Department' do
          cm_section 'Details' do
            form_field :name, input_type: :string
            form_field :logo, input_type: :single_file_upload
            alert_box type: :info, body: 'Only JPEG and PNG files are supported for Logo'
            form_field :name_hindi, input_type: :string, label: 'Name in Hindi'
            form_field :name_odia, input_type: :string, label: 'Name in Odia'
            form_field :name_marathi, input_type: :string, label: 'Name in Marathi'
            form_field :level, input_type: :single_select
            form_field :location_id, input_type: :single_select, helper_method: :select_options_for_location
            form_field :segment_ids, input_type: :multi_select, helper_method: :select_options_for_segment,
                                     display_if: ->(_) { Current.user&.role?('super_admin') }, label: 'Segments'
            nested_form_field :department_contacts, label: 'Contacts' do
              form_field :contact_type, input_type: :single_select
              form_field :email
              form_field :name
              form_field :designation
            end
          end
        end
      end
    end
  end
end
