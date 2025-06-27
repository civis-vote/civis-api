module CmAdmin
  module Category
    extend ActiveSupport::Concern

    included do
      cm_admin do
        actions only: []
        set_icon 'fas fa-tags'
        cm_index do
          page_title 'Categories'

          filter [:name], :search, placeholder: 'Search'

          column :name
          column :cover_photo, field_type: :image
        end

        cm_show page_title: :name do
          tab :profile, '' do
            cm_section 'Category details' do
              field :name
              field :cover_photo, field_type: :image
            end
            cm_section 'Log Details' do
              field :created_at, field_type: :date, format: '%d %b, %Y'
              field :updated_at, field_type: :date, format: '%d %b, %Y', label: 'Last Updated At'
            end
          end
        end

        cm_new page_title: 'Add Category', page_description: 'Enter all details to add Category' do
          cm_section 'Details' do
            form_field :name, input_type: :string
            form_field :cover_photo, input_type: :single_file_upload
          end
        end

        cm_edit page_title: 'Edit Category', page_description: 'Enter all details to edit Category' do
          cm_section 'Details' do
            form_field :name, input_type: :string
            form_field :cover_photo, input_type: :single_file_upload
          end
        end
      end
    end
  end
end
