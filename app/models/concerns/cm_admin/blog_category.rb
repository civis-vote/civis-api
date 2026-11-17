module CmAdmin
  module BlogCategory
    extend ActiveSupport::Concern

    included do
      cm_admin do
        actions only: []
        icon_name 'fas fa-tags'

        cm_index do
          page_title 'Blog Categories'

          filter %i[name], :search, placeholder: 'Search'

          column :id
          column :name
          column :icon_name
          column :hex_code
        end

        cm_show page_title: :name do
          tab :profile, '' do
            cm_section 'Blog Category details' do
              field :name
              field :icon_name
              field :hex_code
            end
            cm_section 'Log Details' do
              field :created_at, field_type: :date, format: '%d %b, %Y'
              field :updated_at, field_type: :date, format: '%d %b, %Y', label: 'Last Updated At'
            end
          end
        end

        cm_new page_title: 'Add Blog Category', page_description: 'Enter all details to add Blog Category' do
          cm_section 'Details' do
            form_field :name
            form_field :icon_name, input_type: :string,
                                   helper_text: 'Font Awesome icon class shown next to the category name, e.g. fas fa-tag'
            form_field :hex_code, input_type: :string,
                                  helper_text: 'Hex colour for the category tag, e.g. #E57373'
          end
        end

        cm_edit page_title: 'Edit Blog Category', page_description: 'Enter all details to edit Blog Category' do
          cm_section 'Details' do
            form_field :name
            form_field :icon_name, input_type: :string,
                                   helper_text: 'Font Awesome icon class shown next to the category name, e.g. fas fa-tag'
            form_field :hex_code, input_type: :string,
                                  helper_text: 'Hex colour for the category tag, e.g. #E57373'
          end
        end
      end
    end
  end
end
