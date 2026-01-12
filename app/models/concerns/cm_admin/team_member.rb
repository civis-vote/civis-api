module CmAdmin
  module TeamMember
    extend ActiveSupport::Concern

    STATUS_TAG_CLASS = { :active => 'completed', :inactive => 'danger' }.freeze

    included do
      cm_admin do
        actions only: []
        set_icon 'fas fa-users'
        permit_additional_fields [segment_ids: []]

        cm_index do
          page_title 'Team Members'

          filter [:name, :designation], :search, placeholder: 'Search team members'

          column :profile_picture, field_type: :image
          column :name
          column :designation
          column :member_type
          column :status, field_type: :tag, tag_class: STATUS_TAG_CLASS
        end

        cm_show page_title: :name do
          tab :profile, '' do
            cm_section 'Member Details' do
              field :profile_picture, field_type: :image
              field :name
              field :designation
              field :linkedin_url
              field :member_type
              field :status, field_type: :tag, tag_class: STATUS_TAG_CLASS
            end

            cm_section 'Log Details' do
              field :created_at, field_type: :date, format: '%d %b, %Y'
              field :updated_at, field_type: :date, format: '%d %b, %Y', label: 'Last Updated At'
            end
          end
        end

        cm_new page_title: 'Add Member',
               page_description: 'Enter details to add a team or advisory member' do
          cm_section 'Details' do
            form_field :profile_picture, input_type: :single_file_upload
            form_field :name, input_type: :string
            form_field :designation, input_type: :string
            form_field :linkedin_url, input_type: :string, label: 'LinkedIn URL'
            form_field :member_type, input_type: :single_select, helper_method: :select_options_for_member_type
            form_field :active, input_type: :switch
          end
        end

        cm_edit page_title: 'Edit Member',
                page_description: 'Update team member details' do
          cm_section 'Details' do
            form_field :profile_picture, input_type: :single_file_upload
            form_field :name, input_type: :string
            form_field :designation, input_type: :string
            form_field :linkedin_url, input_type: :string, label: 'LinkedIn URL'
            form_field :member_type, input_type: :single_select, helper_method: :select_options_for_member_type
            form_field :active, input_type: :switch
          end
        end
      end
    end
  end
end
