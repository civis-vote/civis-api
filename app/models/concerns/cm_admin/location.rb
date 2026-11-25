module CmAdmin
  module Location
    extend ActiveSupport::Concern

    included do
      cm_admin do
        actions only: []
        icon_name 'fas fa-location-dot'
        sort column: 'name', display_name: 'Name', default: true, default_direction: 'asc'

        cm_index do
          page_title 'Locations'

          filter %i[name], :search, placeholder: 'Search'
          filter :location_type, :multi_select
          filter :parent_id, :multi_select, helper_method: :select_options_for_state
          filter :is_international_city, :single_select, helper_method: :select_options_for_boolean

          column :name
          column :location_type, field_type: :enum, header: 'Type'
          column :name, field_type: :association, association_name: :parent, association_type: 'belongs_to',
                        header: 'Parent'
          column :is_international_city, field_type: :boolean, header: 'International City'
        end

        cm_show page_title: :name do
          tab :profile, '' do
            cm_section 'Location details' do
              field :name
              field :location_type, field_type: :enum, label: 'Type'
              field :name, field_type: :association, association_name: :parent, association_type: 'belongs_to',
                           label: 'Parent'
              field :is_international_city, field_type: :boolean, label: 'International City'
            end
            cm_section 'Log Details' do
              field :created_at, field_type: :date, format: '%d %b, %Y'
              field :updated_at, field_type: :date, format: '%d %b, %Y', label: 'Last Updated At'
            end
          end
          tab :children, 'children', associated_model: :children, layout_type: 'cm_association_index' do
            column :name
            column :location_type, field_type: :enum, header: 'Type'
            column :is_international_city, field_type: :boolean, header: 'International City'
          end
        end

        cm_new page_title: 'Add Location', page_description: 'Enter all details to add Location' do
          cm_section 'Details' do
            form_field :name, input_type: :string
            form_field :location_type, input_type: :single_select, label: 'Type'
            form_field :parent_id, input_type: :single_select, helper_method: :select_options_for_state,
                                   label: 'Parent'
            form_field :is_international_city, input_type: :switch, label: 'International City'
          end
        end

        cm_edit page_title: 'Edit Location', page_description: 'Enter all details to edit Location' do
          cm_section 'Details' do
            form_field :name, input_type: :string
            form_field :location_type, input_type: :single_select, label: 'Type'
            form_field :parent_id, input_type: :single_select, helper_method: :select_options_for_state,
                                   label: 'Parent'
            form_field :is_international_city, input_type: :switch, label: 'International City'
          end
        end
      end
    end
  end
end
