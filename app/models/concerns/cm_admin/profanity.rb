module CmAdmin
  module Profanity
    extend ActiveSupport::Concern

    included do
      cm_admin do
        actions only: []
        set_icon 'far fa-newspaper'
        cm_index do
          page_title 'Profanities'

          filter %i[profane_word], :search, placeholder: 'Search'

          importable class_name: 'ImportProfanity', importer_type: 'custom_importer',
                     sample_file_path: '/csv_import_templates/profanity.csv'

          column :profane_word
          column :created_by_full_name, header: 'Created By'
        end

        cm_show page_title: :profane_word do
          tab :profile, '' do
            cm_section 'Profanity details' do
              field :profane_word
              field :created_by_full_name, label: 'Created By'
            end
            cm_section 'Log Details' do
              field :created_at, field_type: :date, format: '%d %b, %Y'
              field :updated_at, field_type: :date, format: '%d %b, %Y', label: 'Last Updated At'
            end
          end
        end

        cm_new page_title: 'Add Profanity', page_description: 'Enter all details to add Profanity' do
          cm_section 'Details' do
            form_field :profane_word, input_type: :string
          end
        end

        cm_edit page_title: 'Edit Profanity', page_description: 'Enter all details to edit Profanity' do
          cm_section 'Details' do
            form_field :profane_word, input_type: :string
          end
        end
      end
    end
  end
end
