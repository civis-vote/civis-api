module CmAdmin
  module Organisation
    extend ActiveSupport::Concern

    included do
      cm_admin do
        actions only: []
        set_icon 'fas fa-building'
        permit_additional_fields [segment_ids: []]
        set_policy_scopes [{ scope_name: 'organisation_only', display_name: 'Organisation Only' }]

        cm_index do
          page_title 'Organisations'

          filter %i[name], :search, placeholder: 'Search'
          filter :active, :single_select, collection: [['Yes', true], ['No', false]]

          column :id
          column :name
          column :users_count, header: 'Employees'
          column :created_at, field_type: :date, header: 'Added On', format: '%d %b, %Y'
          column :created_by_full_name, header: 'Added By'
        end

        cm_show page_title: :name do
          tab :profile, '' do
            cm_section 'Organisation details' do
              field :id, label: 'ID'
              field :name
              field :engagement_type
              field :official_url, label: 'Organisation URL', field_type: :link
              field :logo, field_type: :image
              field :segment_names, label: 'Segments'
              field :created_by_full_name, label: 'Added By'
            end
            cm_section 'Log Details' do
              field :created_at, field_type: :date, format: '%d %b, %Y', label: 'Added On'
              field :updated_at, field_type: :date, format: '%d %b, %Y', label: 'Last Updated At'
            end
          end
          tab :consultations, 'consultations', associated_model: :consultations, layout_type: 'cm_association_index' do
            column :id
            column :title
            column :department_name, header: 'Department'
            column :status, field_type: :tag, tag_class: ::CmAdmin::Consultation::STATUS_TAG_COLORS
            column :response_deadline, field_type: :date, format: '%d %b, %Y'
            column :created_at, field_type: :date, format: '%d %b, %Y'
            column :created_by_full_name, header: 'Created By'
            column :responses_count
          end
          tab :employees, 'employees', associated_model: :users, layout_type: 'cm_association_index' do
            column :email
            column :full_name
            column :profile_picture, field_type: :image
            column :created_at, field_type: :date, format: '%d %b, %Y'
          end
          tab :respondents, 'respondents', associated_model: :respondent_users, layout_type: 'cm_association_index',
                                           associated_model_name: 'Respondent' do
            column :email
            column :full_name
            column :profile_picture, field_type: :image
            column :created_at, field_type: :date, format: '%d %b, %Y'
          end
        end

        cm_new page_title: 'Add Organisation', page_description: 'Enter all details to add Organisation' do
          cm_section 'Details' do
            form_field :name, input_type: :string
            form_field :engagement_type, input_type: :single_select, helper_method: :select_options_for_organisation_engagement_type
            form_field :official_url, input_type: :string
            form_field :logo, input_type: :single_file_upload
            form_field :segment_ids, input_type: :multi_select, helper_method: :select_options_for_segment,
                                     display_if: ->(_) { Current.user&.role?('super_admin') }, label: 'Segments'
          end
        end

        cm_edit page_title: 'Edit Organisation', page_description: 'Enter all details to edit Organisation' do
          cm_section 'Details' do
            form_field :name, input_type: :string
            form_field :engagement_type, input_type: :single_select, helper_method: :select_options_for_organisation_engagement_type
            form_field :official_url, input_type: :string
            form_field :logo, input_type: :single_file_upload
            form_field :segment_ids, input_type: :multi_select, helper_method: :select_options_for_segment,
                                     display_if: ->(_) { Current.user&.role?('super_admin') }, label: 'Segments'
          end
        end
      end
    end
  end
end
