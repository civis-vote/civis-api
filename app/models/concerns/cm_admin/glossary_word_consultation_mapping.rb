module CmAdmin
  module GlossaryWordConsultationMapping
    extend ActiveSupport::Concern

    included do
      cm_admin do
        actions only: []
        set_icon 'fas fa-tags'
        visible_on_sidebar false

        cm_index do
          page_title 'Glossary Consultation Words'

          column :consultation_title
          column :glossary_word, header: 'Word'
        end

        cm_show page_title: :consultation_title do
          tab :profile, '' do
            cm_section 'Glossary Consultation Word details' do
              field :consultation_title
              field :glossary_word, label: 'Word'
            end
            cm_section 'Log Details' do
              field :created_at, field_type: :date, format: '%d %b, %Y'
              field :updated_at, field_type: :date, format: '%d %b, %Y', label: 'Last Updated At'
            end
          end
        end

        cm_new page_title: 'Add Glossary Consultation Word', page_description: 'Enter all details to add Glossary Consultation Word' do
          cm_section 'Details' do
            form_field :consultation_id, input_type: :single_select, helper_method: :select_options_for_consultation
          end
        end

        cm_edit page_title: 'Edit Glossary Consultation Word', page_description: 'Enter all details to edit Glossary Consultation Word' do
          cm_section 'Details' do
            form_field :consultation_id, input_type: :single_select, helper_method: :select_options_for_consultation
          end
        end
      end
    end
  end
end
