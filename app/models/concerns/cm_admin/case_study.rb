module CmAdmin
  module CaseStudy
    extend ActiveSupport::Concern

    included do
      cm_admin do
        actions only: []
        set_icon 'fas fa-file-alt'
        cm_index do
          page_title 'Case Studies'

          filter %i[name ministry_name url], :search, placeholder: 'Search'

          column :name
          column :ministry_name
          column :no_of_citizens
          column :url
          column :created_by_full_name, header: 'Created By'
        end

        cm_show page_title: :name do
          tab :profile, '' do
            cm_section 'Case Study details' do
              field :name
              field :ministry_name
              field :no_of_citizens
              field :url
              field :created_by_full_name, label: 'Created By'
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
          end
        end

        cm_edit page_title: 'Edit Case Study', page_description: 'Enter all details to edit Case Study' do
          cm_section 'Details' do
            form_field :name, input_type: :string
            form_field :ministry_name, input_type: :string
            form_field :no_of_citizens, input_type: :integer
            form_field :url, input_type: :string
          end
        end
      end
    end
  end
end
