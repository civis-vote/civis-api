module CmAdmin
  module User
    extend ActiveSupport::Concern
    CM_ROLE_TAG_CLASS = { Admin: 'completed', Moderator: 'active-two', Citizen: 'active-one' }.freeze

    included do
      cm_admin do
        actions only: []
        set_icon 'fas fa-users'
        permit_additional_fields [segment_ids: []]
        set_policy_scopes [{ scope_name: 'organisation_only', display_name: 'Organisation Only' }]
        sortable_columns [
          { column: 'created_at', display_name: 'Created At', default: true, default_direction: 'desc' },
          { column: 'updated_at', display_name: 'Updated At' },
          { column: 'points', display_name: 'Points' },
          { column: 'rank', display_name: 'Rank' }
        ]

        cm_index do
          page_title 'Users'

          filter %i[email first_name last_name], :search, placeholder: 'Search', active_by_default: :true
          filter :cm_role_id, :multi_select, helper_method: :select_options_for_cm_role, display_name: 'Role',active_by_default: true
          filter :city_id, :multi_select, helper_method: :select_options_for_city ,active_by_default: true
          filter :state_id, :multi_select, helper_method: :select_options_for_state, filter_with: :state_filter, active_by_default: true
          
          filter :created_at, :date, placeholder: 'Created at'
          filter :updated_at, :date, placeholder: 'Updated at'
        

          column :full_name
          column :email
          column :cm_role_name, header: 'Role', field_type: :tag, tag_class: CM_ROLE_TAG_CLASS
          column :created_at, field_type: :date, format: '%d %b, %Y', header: 'Joining Date'
          column :points
          column :city_name, header: 'City'
          column :rank
        end

        cm_show page_title: :full_name do
          bulk_action name: 'delete', display_name: 'Delete', icon_name: 'fa-solid fa-square-xmark', display_type: :modal,
                      success_message: ->(success) { "Successfully Deleted #{success.size} users." },
                      error_message: lambda { |errors|
                        "<p class='mb-0'>Failed to delete #{errors.size} users.</p>
                        <ul>
                          #{errors.map do |error|
                            "<li><a href='/cm_admin/users/#{error.failed_id}' target='_blank'>#{error.row_identifier}</a> #{error.error_message}</li>"
                          end.join}
                        </ul>"
                      },
                      modal_configuration: { title: 'Delete', description: 'Are you sure you want to Delete selected Users', confirmation_text: 'Confirm' } do |id|
            ::User.find(id).destroy
          end

          bulk_action name: 'change_role', display_name: 'Change Role', icon_name: 'fa-solid fa-users-gear', display_type: :form_modal,
                      success_message: ->(success) { "Successfully Updated Role for #{success.size} users." },
                      error_message: lambda { |errors|
                        "<p class='mb-0'>Failed to update role for #{errors.size} users.</p>
                        <ul>
                          #{errors.map do |error|
                            "<li><a href='/cm_admin/users/#{error.failed_id}' target='_blank'>#{error.row_identifier}</a> #{error.error_message}</li>"
                          end.join}
                        </ul>"
                      },
                      modal_configuration: { title: 'Change Role', confirmation_text: 'Confirm' } do
            form do
              cm_section '' do
                form_field :cm_role_id, input_type: :single_select, helper_method: :select_options_for_assignable_cm_role,
                                        label: 'Role', placeholder: 'Select Role', is_required: true
              end
            end
            on_submit do |id|
              raise 'Role is required' if params.dig(:user, :cm_role_id).blank?

              @user = ::User.find(id)
              @user.update!(cm_role_id: params.dig(:user, :cm_role_id))
              @user
            end
          end

          tab :profile, '' do
            cm_show_section 'User Details' do
              field :first_name
              field :last_name
              field :email
              field :cm_role_name, label: 'Role', field_type: :tag, tag_class: CM_ROLE_TAG_CLASS
              field :points
              field :city_name, header: 'City'
              field :rank
              field :phone_number
              field :profile_picture, field_type: :image
              field :name, field_type: :association, association_name: 'organisation', association_type: 'belongs_to',
                           label: 'Organisation'
              field :segment_names, label: 'Segments'
            end
            cm_section 'Log Details' do
              field :created_at, field_type: :date, format: '%d %b, %Y', label: 'Joining Date'
              field :updated_at, field_type: :date, format: '%d %b, %Y', label: 'Last Updated At'
              field :last_active_at, field_type: :date, format: '%d %b, %Y'
            end
          end
          tab :responses, 'responses', associated_model: 'responses', layout_type: 'cm_association_index',
                                       associated_model_name: 'ConsultationResponse' do
            column :id
            column :consultation_title
            column :user_response
            column :response_status, header: 'Status', field_type: :enum
          end
        end

        cm_new page_title: 'Add User', page_description: 'Enter all details to add User' do
          cm_section 'Details' do
            form_field :email, input_type: :string
            form_field :first_name, input_type: :string
            form_field :last_name, input_type: :string
            form_field :cm_role_id, input_type: :single_select, helper_method: :select_options_for_assignable_cm_role,
                                    label: 'Role', placeholder: 'Select Role'
            form_field :segment_ids, input_type: :multi_select, helper_method: :select_options_for_segment,
                                     display_if: ->(_) { Current.user&.role?('super_admin') }, label: 'Segments'
          end
        end

        cm_edit page_title: 'Edit User', page_description: 'Enter all details to edit User' do
          cm_section 'Details' do
            form_field :email, input_type: :string
            form_field :first_name, input_type: :string
            form_field :last_name, input_type: :string
            form_field :cm_role_id, input_type: :single_select, helper_method: :select_options_for_assignable_cm_role,
                                    label: 'Role', placeholder: 'Select Role'
            form_field :segment_ids, input_type: :multi_select, helper_method: :select_options_for_segment,
                                     display_if: ->(_) { Current.user&.role?('super_admin') }, label: 'Segments'
          end
        end
      end
    end
  end
end
