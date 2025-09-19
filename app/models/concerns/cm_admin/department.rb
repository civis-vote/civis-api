module CmAdmin
  module Department
    extend ActiveSupport::Concern

    STATUS_TAG_COLORS = { approved: 'bg-success', not_approved: 'bg-danger' }.freeze

    included do
      cm_admin do
        actions only: []
        set_icon 'fas fa-suitcase'
        permit_additional_fields [segment_ids: []]
        cm_index do
          page_title 'Departments'

          filter %i[name], :search, placeholder: 'Search'
          filter :status, :single_select, collection: [%w[Approved true], ['Not Approved', false]],
                                          filter_with: :status_filter

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
          column :theme_name, header: 'Theme'
          column :status, field_type: :tag, tag_class: STATUS_TAG_COLORS
          column :location_name, header: 'Location'
        end

        cm_show page_title: :name do
          tab :profile, '' do
            cm_section 'Department details' do
              field :name
              field :logo, field_type: :image
              field :name_hindi, label: 'Name in Hindi'
              field :name_odia, label: 'Name in Odia'
              field :name_marathi, label: 'Name in Marathi'
              field :level, field_type: :enum
              field :theme_name, label: 'Theme'
              field :status, field_type: :tag, tag_class: STATUS_TAG_COLORS
              field :poc_email_primary, label: 'Primary Email Address'
              field :primary_officer_name
              field :primary_officer_designation
              field :poc_email_secondary, label: 'Secondary Email Address'
              field :secondary_officer_name
              field :secondary_officer_designation
              field :location_name, label: 'Location'
              field :segment_names, label: 'Segments'
              field :created_by_full_name, label: 'Created By'
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
            form_field :theme_id, input_type: :single_select, helper_method: :select_options_for_theme
            form_field :poc_email_primary, input_type: :string, label: 'Primary Email Address'
            form_field :primary_officer_name, input_type: :string, label: 'Primary Officer Name'
            form_field :primary_officer_designation, input_type: :string, label: 'Primary Officer Designation'
            form_field :poc_email_secondary, input_type: :string, label: 'Secondary Email Address'
            form_field :secondary_officer_name, input_type: :string, label: 'Secondary Officer Name'
            form_field :secondary_officer_designation, input_type: :string, label: 'Secondary Officer Designation'
            form_field :location_id, input_type: :single_select, helper_method: :select_options_for_location
            form_field :segment_ids, input_type: :multi_select, helper_method: :select_options_for_segment,
                                     display_if: ->(_) { Current.user&.role?('super_admin') }
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
            form_field :theme_id, input_type: :single_select, helper_method: :select_options_for_theme
            form_field :poc_email_primary, input_type: :string, label: 'Primary Email Address'
            form_field :primary_officer_name, input_type: :string, label: 'Primary Officer Name'
            form_field :primary_officer_designation, input_type: :string, label: 'Primary Officer Designation'
            form_field :poc_email_secondary, input_type: :string, label: 'Secondary Email Address'
            form_field :secondary_officer_name, input_type: :string, label: 'Secondary Officer Name'
            form_field :secondary_officer_designation, input_type: :string, label: 'Secondary Officer Designation'
            form_field :location_id, input_type: :single_select, helper_method: :select_options_for_location
            form_field :segment_ids, input_type: :multi_select, helper_method: :select_options_for_segment,
                                     display_if: ->(_) { Current.user&.role?('super_admin') }
          end
        end
      end
    end
  end
end
