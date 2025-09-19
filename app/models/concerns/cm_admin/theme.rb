module CmAdmin
  module Theme
    extend ActiveSupport::Concern

    included do
      cm_admin do
        actions only: []
        set_icon 'fas fa-tags'
        permit_additional_fields [segment_ids: []]

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
              field :segment_names, label: 'Segments'
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
            form_field :segment_ids, input_type: :multi_select, helper_method: :select_options_for_segment,
                                     display_if: ->(_) { Current.user&.role?('super_admin') }, label: 'Segments'
          end
        end

        cm_edit page_title: 'Edit Theme', page_description: 'Enter all details to edit Theme' do
          cm_section 'Details' do
            form_field :name, input_type: :string
            form_field :cover_photo, input_type: :single_file_upload
            form_field :segment_ids, input_type: :multi_select, helper_method: :select_options_for_segment,
                                     display_if: ->(_) { Current.user&.role?('super_admin') }, label: 'Segments'
          end
        end
      end
    end
  end
end
