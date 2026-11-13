module CmAdmin
  module Theme
    extend ActiveSupport::Concern
    STATUS_TAG_COLORS = { active: 'cm-badge-green', disabled: 'cm-badge-red' }.freeze

    included do
      cm_admin do
        actions only: []
        icon_name 'fas fa-tags'

        cm_index do
          page_title 'Themes'

          filter [:name], :search, placeholder: 'Search'

          column :name
          column :icon_name
          column :status, field_type: :badge, badge_class: STATUS_TAG_COLORS
        end

        cm_show page_title: :name do
          custom_action name: 'disable_theme', route_type: 'member', verb: 'patch', icon_name: 'fa-solid fa-ban',
                        display_if: lambda(&:active?),
                        modal_configuration: { title: 'Disable Theme', confirmation_text: 'Confirm',
                                               description: 'Are you sure you want to disable this theme?' },
                        path: ':id/disable_theme', display_type: :modal do
            @theme = ::Theme.find(params[:id])
            @theme.disabled!
            @theme
          end

          custom_action name: 'activate_theme', route_type: 'member', verb: 'patch', icon_name: 'fa-regular fa-circle-check',
                        display_if: lambda(&:disabled?),
                        modal_configuration: { title: 'Activate Theme', confirmation_text: 'Confirm',
                                               description: 'Are you sure you want to activate this theme?' },
                        path: ':id/activate_theme', display_type: :modal do
            @theme = ::Theme.find(params[:id])
            @theme.active!
            @theme
          end

          tab :profile, '' do
            cm_section 'Theme details' do
              field :name
              field :icon_name
              field :status, field_type: :badge, badge_class: STATUS_TAG_COLORS
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
            form_field :icon_name, input_type: :string,
                                   helper_text: 'Font Awesome icon class shown next to the theme name, e.g. fas fa-tag'
          end
        end

        cm_edit page_title: 'Edit Theme', page_description: 'Enter all details to edit Theme' do
          cm_section 'Details' do
            form_field :name, input_type: :string
            form_field :icon_name, input_type: :string,
                                   helper_text: 'Font Awesome icon class shown next to the theme name, e.g. fas fa-tag'
          end
        end
      end
    end
  end
end
