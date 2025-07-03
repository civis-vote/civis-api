module CmAdmin
  module User
    extend ActiveSupport::Concern
    STATUS_TAG_CLASS = { active: 'bg-success', disabled: 'bg-danger' }.freeze

    included do
      cm_admin do
        actions only: []
        set_icon 'fas fa-users'
        cm_index do
          page_title 'Users'

          sortable_columns [{ column: 'created_at', display_name: 'Created At', default_direction: 'desc', default: true },
                            { column: 'updated_at', display_name: 'Updated At' },
                            { column: 'last_active_at', display_name: 'Last Active At' }]

          filter %i[email first_name last_name], :search, placeholder: 'Search'
          filter :status, :single_select, collection: [%w[Active active], %w[Disabled disabled]]
          filter :created_at, :date, placeholder: 'Created at'
          filter :updated_at, :date, placeholder: 'Updated at'

          column :full_name
          column :email
          column :cm_role_name, header: 'Role'
          column :created_at, field_type: :date, format: '%d %b, %Y', header: 'Joining Date'
          column :points
          column :city_name, header: 'City'
          column :rank
        end

        cm_show page_title: :full_name do
          tab :profile, '' do
            cm_show_section 'User Details' do
              field :first_name
              field :last_name
              field :email
              field :cm_role_name, label: 'Role'
            end
            cm_section 'Log Details' do
              field :created_at, field_type: :date, format: '%d %b, %Y'
              field :updated_at, field_type: :date, format: '%d %b, %Y', label: 'Last Updated At'
            end
          end
        end

        cm_new page_title: 'Add User', page_description: 'Enter all details to add User' do
          cm_section 'Details' do
            form_field :email, input_type: :string
            form_field :first_name, input_type: :string
            form_field :last_name, input_type: :string
            form_field :cm_role_id, input_type: :single_select, helper_method: :select_options_for_cm_role,
                                    label: 'Role', placeholder: 'Select Role'
          end
        end

        cm_edit page_title: 'Edit User', page_description: 'Enter all details to edit User' do
          cm_section 'Details' do
            form_field :email, input_type: :string
            form_field :first_name, input_type: :string
            form_field :last_name, input_type: :string
            form_field :cm_role_id, input_type: :single_select, helper_method: :select_options_for_cm_role,
                                    label: 'Role', placeholder: 'Select Role'
          end
        end
      end
    end
  end
end
