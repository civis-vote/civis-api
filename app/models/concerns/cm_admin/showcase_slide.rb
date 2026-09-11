module CmAdmin
  module ShowcaseSlide
    extend ActiveSupport::Concern

    STATUS_TAG_COLORS = { draft: 'cm-badge-cyan', published: 'cm-badge-green',
                          archived: 'cm-badge-gray' }.freeze

    included do
      cm_admin do
        actions only: []
        set_icon 'fas fa-images'

        sortable_columns [
          { column: 'position', display_name: 'Display Order', default: true, default_direction: 'asc' },
          { column: 'created_at', display_name: 'Created At' },
          { column: 'updated_at', display_name: 'Updated At' }
        ]

        cm_index do
          page_title 'Showcase Slides'

          filter [:title], :search, placeholder: 'Search'
          filter :status, :multi_select, active_by_default: true

          column :id
          column :title
          column :status, field_type: :tag, tag_class: STATUS_TAG_COLORS
          column :position, header: 'Display Order'
          column :cta_label, header: 'CTA Label'
          column :url
          column :video_url, header: 'Video URL'
          column :published_at, field_type: :date, format: '%d %b, %Y'
          column :archived_at, field_type: :date, format: '%d %b, %Y'
          column :created_by_full_name, header: 'Created By'
          column :created_at, field_type: :date, format: '%d %b, %Y'
        end

        cm_show page_title: :title do
          custom_action name: 'publish', route_type: 'member', verb: 'patch', path: ':id/publish',
                        icon_name: 'fa-solid fa-check', display_type: :button,
                        display_if: ->(slide) { slide.draft? || slide.archived? } do
            slide = ::ShowcaseSlide.find(params[:id])
            slide.publish
            slide
          end

          custom_action name: 'archive', route_type: 'member', verb: 'patch', path: ':id/archive',
                        icon_name: 'fa-solid fa-box-archive', display_type: :button,
                        display_if: lambda(&:published?) do
            slide = ::ShowcaseSlide.find(params[:id])
            slide.archive
            slide
          end

          tab :profile, '' do
            cm_section 'Slide details' do
              field :title
              field :description
              field :banner_type, label: 'Banner Type'
              field :image, field_type: :image
              field :url, label: 'CTA URL'
              field :video_url, label: 'Video URL'
              field :cta_label, label: 'CTA Label'
              field :status, field_type: :tag, tag_class: STATUS_TAG_COLORS
              field :position, label: 'Display Order'
              field :published_at, field_type: :datetime
              field :archived_at, field_type: :datetime
            end
            cm_section 'Log Details' do
              field :created_by_full_name, label: 'Created By'
              field :created_at, field_type: :date, format: '%d %b, %Y'
              field :updated_by_full_name, label: 'Updated By'
              field :updated_at, field_type: :date, format: '%d %b, %Y', label: 'Last Updated At'
            end
          end
        end

        cm_new page_title: 'Add Showcase Slide', page_description: 'Enter all details to add Showcase Slide' do
          cm_section 'Details' do
            form_field :title, input_type: :string
            form_field :description, input_type: :rich_text
            form_field :banner_type, input_type: :single_select,
                                     label: 'Banner Type',
                                     collection: [%w[Image image], %w[Video video]],
                                     helper_text: 'Choose Image to upload an image, or Video to provide a video URL.',
                                     html_attrs: { 'data-action': 'change->fields#show',
                                                   'data-cm-visible-id': 'image video_url',
                                                   'data-cm-toggle-values': '{"image":"image","video":"video"}' }
            form_field :image, input_type: :single_file_upload,
                               html_attrs: { 'data-fields-target': 'cmVisible', 'data-cm-id': 'image' }
            form_field :url, input_type: :string, label: 'CTA URL'
            form_field :video_url, input_type: :string, label: 'Video URL',
                                   html_attrs: { 'data-fields-target': 'cmVisible', 'data-cm-id': 'video' }
            form_field :cta_label, input_type: :string, label: 'CTA Label'
            form_field :position, input_type: :integer, label: 'Display Order',
                                  helper_text: 'Controls the display order on the Home Page (ascending).'
          end
        end

        cm_edit page_title: 'Edit Showcase Slide', page_description: 'Enter all details to edit Showcase Slide' do
          cm_section 'Details' do
            form_field :title, input_type: :string
            form_field :description, input_type: :rich_text
            form_field :banner_type, input_type: :single_select,
                                     label: 'Banner Type',
                                     collection: [%w[Image image], %w[Video video]],
                                     helper_text: 'Choose Image to upload an image, or Video to provide a video URL.',
                                     html_attrs: { 'data-action': 'change->fields#show',
                                                   'data-cm-visible-id': 'image video_url',
                                                   'data-cm-toggle-values': '{"image":"image","video":"video"}' }
            form_field :image, input_type: :single_file_upload,
                               html_attrs: { 'data-fields-target': 'cmVisible', 'data-cm-id': 'image' }
            form_field :url, input_type: :string, label: 'CTA URL'
            form_field :video_url, input_type: :string, label: 'Video URL',
                                   html_attrs: { 'data-fields-target': 'cmVisible', 'data-cm-id': 'video' }
            form_field :cta_label, input_type: :string, label: 'CTA Label'
            form_field :position, input_type: :integer, label: 'Display Order',
                                  helper_text: 'Controls the display order on the Home Page (ascending).'
          end
        end
      end
    end
  end
end
