module CmAdmin
  module Clause
    extend ActiveSupport::Concern

    included do
      cm_admin do
        actions only: []
        set_icon 'fas fa-file-contract'
        permit_additional_fields [clause_type_id: []]

        sortable_columns [
          { column: 'created_at', display_name: 'Created At' },
          { column: 'clause_id', display_name: 'Clause ID', default: true, default_direction: 'asc' }
        ]

        cm_index do
          page_title 'Clauses'

          filter %i[clause_id clause_title], :search, placeholder: 'Search'
          filter :clause_type_id, :multi_select, helper_method: :select_options_for_clause_type

          column :clause_id
          column :clause_title
          column :clause_type_name, header: 'Clause Type'
          column :stakeholder_impact
          column :keywords
          column :what_is_being_proposed
          column :created_at, field_type: :date, format: '%d %b, %Y'
        end

        cm_show page_title: :clause_title do
          tab :profile, '' do
            cm_show_section 'Clause details' do
              field :clause_id, label: 'Clause ID'
              field :clause_title
              field :clause_type_name, label: 'Clause Type'
              field :stakeholder_impact
              field :keywords
              field :what_is_being_proposed
            end
            cm_section 'Log Details' do
              field :created_at, field_type: :date, format: '%d %b, %Y'
              field :updated_at, field_type: :date, format: '%d %b, %Y', label: 'Last Updated At'
            end
          end
        end

        cm_new page_title: 'Add Clause', page_description: 'Enter all details to add Clause' do
          cm_section 'Details' do
            form_field :clause_id, input_type: :string, label: 'Clause ID'
            form_field :clause_title, input_type: :string
            form_field :what_is_being_proposed, input_type: :text
            form_field :clause_type_id, input_type: :single_select, helper_method: :select_options_for_clause_type
            form_field :stakeholder_impact, input_type: :string
            form_field :keywords, input_type: :string
          end
        end

        cm_edit page_title: 'Edit Clause', page_description: 'Enter all details to edit Clause' do
          cm_section 'Details' do
            form_field :clause_id, input_type: :string, label: 'Clause ID'
            form_field :clause_title, input_type: :string
            form_field :what_is_being_proposed, input_type: :text
            form_field :clause_type_id, input_type: :single_select, helper_method: :select_options_for_clause_type
            form_field :stakeholder_impact, input_type: :string
            form_field :keywords, input_type: :string
          end
        end
      end
    end
  end
end
