module CmAdmin
  module Consultation
    extend ActiveSupport::Concern

    STATUS_TAG_COLORS = { submitted: 'bg-info', published: 'bg-success', rejected: 'bg-danger', expired: 'bg-dark' }.freeze

    included do
      cm_admin do
        actions only: []
        set_icon 'fas fa-clipboard-list'
        cm_index do
          page_title 'Consultations'

          filter %i[title], :search, placeholder: 'Search'

          column :title
          column :ministry_name, header: 'Ministry'
          column :status, field_type: :tag, tag_class: STATUS_TAG_COLORS
          column :response_deadline, field_type: :date, format: '%d %b, %Y'
          column :created_by_full_name, header: 'Created By'
        end

        cm_show page_title: :title do
          tab :profile, '' do
            cm_section 'Consultation details' do
              field :title
              field :title_hindi, label: 'Title in Hindi'
              field :title_odia, label: 'Title in Odia'
              field :title_marathi, label: 'Title in Marathi'
              field :consultation_feedback_email
              field :officer_name
              field :officer_designation
              field :url, label: 'URL of Consultation PDF'
              field :ministry_name, label: 'Ministry'
              field :review_type, field_type: :enum
              field :visibility, field_type: :enum
              field :response_deadline, field_type: :date, format: '%d %b, %Y'
              field :show_discuss_section, field_type: :custom, helper_method: :format_boolean_value
              field :status, field_type: :tag, tag_class: STATUS_TAG_COLORS
              field :feedback_url, label: 'Consultation Page', field_type: :link
              field :response_url, label: 'Consultation Summary', field_type: :link
              field :consultation_logo, field_type: :image
              field :created_by_full_name, label: 'Created By'
            end
            cm_section 'Log Details' do
              field :created_at, field_type: :date, format: '%d %b, %Y'
              field :updated_at, field_type: :date, format: '%d %b, %Y', label: 'Last Updated At'
            end
          end
        end

        cm_new page_title: 'Add Consultation', page_description: 'Enter all details to add Consultation' do
          cm_section 'Details' do
            form_field :title, input_type: :string
          end
        end

        cm_edit page_title: 'Edit Consultation', page_description: 'Enter all details to edit Consultation' do
          cm_section 'Details' do
            form_field :title, input_type: :string
          end
        end
      end
    end
  end
end
