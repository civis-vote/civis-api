module CmAdmin
  module Ministry
    extend ActiveSupport::Concern

    included do
      cm_admin do
        actions only: []
        set_icon 'fas fa-suitcase'
        cm_index do
          page_title 'Ministries'

          filter %i[name], :search, placeholder: 'Search'

          column :name
          column :created_by_full_name, header: 'Created By'
          column :category_name, header: 'Category'
          column :status
          column :location_name, header: 'Location'
        end

        cm_show page_title: :name do
          tab :profile, '' do
            cm_section 'Ministry details' do
              field :name
              field :logo, field_type: :image
              field :name_hindi, label: 'Name in Hindi'
              field :name_odia, label: 'Name in Odia'
              field :name_marathi, label: 'Name in Marathi'
              field :level, field_type: :enum
              field :category_name, label: 'Category'
              field :status
              field :poc_email_primary, label: 'Primary Email Address'
              field :primary_officer_name
              field :primary_officer_designation
              field :poc_email_secondary, label: 'Secondary Email Address'
              field :secondary_officer_name
              field :secondary_officer_designation
              field :location_name, label: 'Location'
              field :created_by_full_name, label: 'Created By'
            end
            cm_section 'Log Details' do
              field :created_at, field_type: :date, format: '%d %b, %Y'
              field :updated_at, field_type: :date, format: '%d %b, %Y', label: 'Last Updated At'
            end
          end
        end

        cm_new page_title: 'Add Ministry', page_description: 'Enter all details to add Ministry' do
          cm_section 'Details' do
            form_field :name, input_type: :string
            form_field :logo, input_type: :single_file_upload
            form_field :name_hindi, input_type: :string, label: 'Name in Hindi'
            form_field :name_odia, input_type: :string, label: 'Name in Odia'
            form_field :name_marathi, input_type: :string, label: 'Name in Marathi'
            form_field :level, input_type: :single_select
            form_field :category_id, input_type: :single_select, helper_method: :select_options_for_category
            form_field :poc_email_primary, input_type: :string, label: 'Primary Email Address'
            form_field :primary_officer_name, input_type: :string, label: 'Primary Officer Name'
            form_field :primary_officer_designation, input_type: :string, label: 'Primary Officer Designation'
            form_field :poc_email_secondary, input_type: :string, label: 'Secondary Email Address'
            form_field :secondary_officer_name, input_type: :string, label: 'Secondary Officer Name'
            form_field :secondary_officer_designation, input_type: :string, label: 'Secondary Officer Designation'
            form_field :location_id, input_type: :single_select, helper_method: :select_options_for_location
          end
        end

        cm_edit page_title: 'Edit Ministry', page_description: 'Enter all details to edit Ministry' do
          cm_section 'Details' do
            form_field :name, input_type: :string
            form_field :logo, input_type: :single_file_upload
            form_field :name_hindi, input_type: :string, label: 'Name in Hindi'
            form_field :name_odia, input_type: :string, label: 'Name in Odia'
            form_field :name_marathi, input_type: :string, label: 'Name in Marathi'
            form_field :level, input_type: :single_select
            form_field :category_id, input_type: :single_select, helper_method: :select_options_for_category
            form_field :poc_email_primary, input_type: :string, label: 'Primary Email Address'
            form_field :primary_officer_name, input_type: :string, label: 'Primary Officer Name'
            form_field :primary_officer_designation, input_type: :string, label: 'Primary Officer Designation'
            form_field :poc_email_secondary, input_type: :string, label: 'Secondary Email Address'
            form_field :secondary_officer_name, input_type: :string, label: 'Secondary Officer Name'
            form_field :secondary_officer_designation, input_type: :string, label: 'Secondary Officer Designation'
            form_field :location_id, input_type: :single_select, helper_method: :select_options_for_location
          end
        end
      end
    end
  end
end
