module CmAdmin
  module CaseStudy
    extend ActiveSupport::Concern

    included do
      cm_admin do
        actions only: []
        set_icon 'fas fa-file-alt'
        permit_additional_fields [segment_ids: []]

        cm_index do
          page_title 'Case Studies'

          filter %i[name ministry_name url], :search, placeholder: 'Search'

          column :name
          column :ministry_name
          column :no_of_citizens
          column :url
          column :case_study_type, field_type: :enum
          column :created_by_full_name, header: 'Created By'
        end

        cm_show page_title: :name do
          tab :profile, '' do
            cm_section 'Case Study details' do
              field :name
              field :ministry_name
              field :no_of_citizens
              field :url
              field :case_study_type, field_type: :enum
              field :hero_image, field_type: :image
              field :description, field_type: :rich_text
              field :name, field_type: :association, association_name: :theme, association_type: :belongs_to,
                           label: 'Theme'
              field :created_by_full_name, label: 'Created By'
              field :segment_names, label: 'Segments'
            end
            cm_section 'Log Details' do
              field :created_at, field_type: :date, format: '%d %b, %Y'
              field :updated_at, field_type: :date, format: '%d %b, %Y', label: 'Last Updated At'
            end
          end
        end

        cm_new page_title: 'Add Case Study', page_description: 'Enter all details to add Case Study' do
          cm_section 'Details' do
            form_field :name, input_type: :string
            form_field :ministry_name, input_type: :string
            form_field :no_of_citizens, input_type: :integer
            form_field :url, input_type: :string
            form_field :case_study_type, input_type: :single_select
            form_field :hero_image, input_type: :single_file_upload
            form_field :description, input_type: :rich_text
            form_field :theme_id, input_type: :single_select, helper_method: :select_options_for_theme
            form_field :segment_ids, input_type: :multi_select, helper_method: :select_options_for_segment,
                                     display_if: ->(_) { Current.user&.role?('super_admin') }, label: 'Segments'
          end
        end

        cm_edit page_title: 'Edit Case Study', page_description: 'Enter all details to edit Case Study' do
          cm_section 'Details' do
            form_field :name, input_type: :string
            form_field :ministry_name, input_type: :string
            form_field :no_of_citizens, input_type: :integer
            form_field :url, input_type: :string
            form_field :case_study_type, input_type: :single_select
            form_field :hero_image, input_type: :single_file_upload
            form_field :description, input_type: :rich_text
            form_field :theme_id, input_type: :single_select, helper_method: :select_options_for_theme
            form_field :segment_ids, input_type: :multi_select, helper_method: :select_options_for_segment,
                                     display_if: ->(_) { Current.user&.role?('super_admin') }, label: 'Segments'
          end
        end
      end
    end
  end
end
