module CmAdmin
  module Wordindex
    extend ActiveSupport::Concern

    included do
      cm_admin do
        actions only: []
        set_icon 'far fa-newspaper'
        cm_index do
          page_title 'Word Indices'

          filter %i[word description], :search, placeholder: 'Search'

          importable class_name: 'ImportWordindex', importer_type: 'custom_importer',
                     sample_file_path: '/csv_import_templates/wordindex.csv'

          column :word
          column :description
          column :created_by_full_name, header: 'Created By'
        end

        cm_show page_title: :word do
          tab :profile, '' do
            cm_section 'Word Index details' do
              field :word
              field :description
              field :created_by_full_name, label: 'Created By'
            end
            cm_section 'Log Details' do
              field :created_at, field_type: :date, format: '%d %b, %Y'
              field :updated_at, field_type: :date, format: '%d %b, %Y', label: 'Last Updated At'
            end
          end
          tab :map_word, 'map_word', associated_model: :glossary_word_consultation_mappings, layout_type: 'cm_association_index' do
            column :consultation_title
            column :glossary_word, header: 'Word'
          end
        end

        cm_new page_title: 'Add Word Index', page_description: 'Enter all details to add Word Index' do
          cm_section 'Details' do
            form_field :word, input_type: :string
            form_field :description, input_type: :text
          end
        end

        cm_edit page_title: 'Edit Word Index', page_description: 'Enter all details to edit Word Index' do
          cm_section 'Details' do
            form_field :word, input_type: :string
            form_field :description, input_type: :text
          end
        end
      end
    end
  end
end
