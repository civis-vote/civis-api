module CmAdmin
  module Theme
    extend ActiveSupport::Concern

    included do
      cm_admin do
        actions only: []
        icon_name 'fas fa-tags'

        cm_index do
          page_title 'Themes'

          filter [:name], :search, placeholder: 'Search'

          column :name
          column :cover_photo, field_type: :image
        end

        cm_show page_title: :name do
          tab :profile, '' do
            cm_section 'Theme details' do
              field :name
              field :cover_photo, field_type: :image
            end
            cm_section 'Log Details' do
              field :created_at, field_type: :date, format: '%d %b, %Y'
              field :updated_at, field_type: :date, format: '%d %b, %Y', label: 'Last Updated At'
            end
          end
        end

        cm_new page_title: 'Add Theme', page_description: 'Enter all details to add Theme' do
          cm_section 'Details' do
            form_field :name, input_type: :string
            form_field :cover_photo, input_type: :single_file_upload
          end
        end

        cm_edit page_title: 'Edit Theme', page_description: 'Enter all details to edit Theme' do
          cm_section 'Details' do
            form_field :name, input_type: :string
            form_field :cover_photo, input_type: :single_file_upload
          end
        end
      end
    end
  end
end
