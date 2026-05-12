module CmAdmin
  module Constant
    extend ActiveSupport::Concern

    included do
      cm_admin do
        actions only: []
        set_icon 'fas fa-tags'

        cm_index do
          page_title 'Constants'

          filter :constant_type, :multi_select
          filter %i[name], :search, placeholder: 'Search'

          column :name
          column :constant_type, field_type: :enum
          column :created_at, field_type: :date, format: '%d %b, %Y'
        end

        cm_show page_title: :name do
          cm_section 'Constant details' do
            field :name
            field :constant_type, field_type: :enum
          end
          cm_section 'Log Details' do
            field :created_at, field_type: :date, format: '%d %b, %Y'
            field :updated_at, field_type: :date, format: '%d %b, %Y', label: 'Last Updated At'
          end
        end

        cm_new page_title: 'Add Constant', page_description: 'Enter all details to add Constant' do
          cm_section 'Details' do
            form_field :name, input_type: :string
            form_field :constant_type, input_type: :single_select
          end
        end

        cm_edit page_title: 'Edit Constant', page_description: 'Enter all details to edit Constant' do
          cm_section 'Details' do
            form_field :name, input_type: :string
            form_field :constant_type, input_type: :single_select
          end
        end
      end
    end
  end
end
