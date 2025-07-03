module CmAdmin
  module Organisation
    extend ActiveSupport::Concern

    included do
      cm_admin do
        actions only: []
        set_icon 'fas fa-building'
        cm_index do
          page_title 'Organisations'

          filter %i[name], :search, placeholder: 'Search'

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
              field :official_url, label: 'Organisation URL', field_type: :link
              field :logo, field_type: :image
              field :created_by_full_name, label: 'Added By'
            end
            cm_section 'Log Details' do
              field :created_at, field_type: :date, format: '%d %b, %Y', label: 'Added On'
              field :updated_at, field_type: :date, format: '%d %b, %Y', label: 'Last Updated At'
            end
          end
          tab :employees, 'employees', associated_model: :users, layout_type: 'cm_association_index' do
            column :email
            column :full_name
            column :created_at, field_type: :date, format: '%d %b, %Y'
          end
        end

        cm_new page_title: 'Add Organisation', page_description: 'Enter all details to add Organisation' do
          cm_section 'Details' do
            form_field :name, input_type: :string
            form_field :official_url, input_type: :string
            form_field :logo, input_type: :single_file_upload
          end
        end

        cm_edit page_title: 'Edit Organisation', page_description: 'Enter all details to edit Organisation' do
          cm_section 'Details' do
            form_field :name, input_type: :string
            form_field :official_url, input_type: :string
            form_field :logo, input_type: :single_file_upload
          end
        end
      end
    end
  end
end
