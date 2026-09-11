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
          { column: 'position', display_name: 'Position', default: true, default_direction: 'asc' },
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
          column :position, header: 'Position'
          column :published_at, field_type: :date, format: '%d %b, %Y'
          column :archived_at, field_type: :date, format: '%d %b, %Y'
          column :created_by_full_name, header: 'Created By'
          column :created_at, field_type: :date, format: '%d %b, %Y'
        end

        cm_show page_title: :title do
          custom_action name: 'publish', route_type: 'member', verb: 'patch', path: ':id/publish',
                        icon_name: 'fa-solid fa-check', display_type: :modal,
                        modal_configuration: {
                          title: 'Publish Showcase Slide',
                          description: 'Are you sure you want to publish this showcase slide?',
                          confirmation_text: 'Publish'
                        },
                        display_if: ->(slide) { slide.draft? || slide.archived? } do
            slide = ::ShowcaseSlide.find(params[:id])
            slide.publish
            slide
          end

          custom_action name: 'archive', route_type: 'member', verb: 'patch', path: ':id/archive',
                        icon_name: 'fa-solid fa-box-archive', display_type: :modal,
                        modal_configuration: {
                          title: 'Archive Showcase Slide',
                          description: 'Are you sure you want to archive this showcase slide?',
                          confirmation_text: 'Archive'
                        },
                        display_if: lambda(&:published?) do
            slide = ::ShowcaseSlide.find(params[:id])
            slide.archive
            slide
          end

          tab :profile, '' do
            cm_section 'Slide details' do
              field :title
              field :description
              field :image, field_type: :image, display_if: ->(slide) { slide.image.attached? }
              field :video_url, label: 'Video URL', display_if: ->(slide) { slide.video_url.present? }
              field :cta_label
              field :cta_url, label: 'CTA URL'
              field :status, field_type: :tag, tag_class: STATUS_TAG_COLORS
              field :position, label: 'Position'
            end
            cm_section 'Log Details' do
              field :created_by_full_name, label: 'Created By'
              field :created_at, field_type: :date, format: '%d %b, %Y'
              field :updated_by_full_name, label: 'Updated By'
              field :updated_at, field_type: :date, format: '%d %b, %Y', label: 'Last Updated At'
              field :published_at, field_type: :datetime
              field :archived_at, field_type: :datetime
            end
          end
        end

        cm_new page_title: 'Add Showcase Slide', page_description: 'Enter all details to add Showcase Slide' do
          cm_section 'Details' do
            form_field :title
            form_field :description, input_type: :rich_text
            form_field :image, input_type: :single_file_upload
            form_field :video_url, label: 'Video URL', helper_text: 'Provide a Youtube video URL for video banners.'
            form_field :cta_label
            form_field :cta_url, label: 'CTA URL'
            form_field :position, input_type: :integer, label: 'Position',
                                  helper_text: 'Controls the display order on the Home Page (ascending).'
          end
        end

        cm_edit page_title: 'Edit Showcase Slide', page_description: 'Enter all details to edit Showcase Slide' do
          cm_section 'Details' do
            form_field :title
            form_field :description, input_type: :rich_text
            form_field :image, input_type: :single_file_upload
            form_field :video_url, label: 'Video URL', helper_text: 'Provide a Youtube video URL for video banners.'
            form_field :cta_label
            form_field :cta_url, label: 'CTA URL'
            form_field :position, input_type: :integer, label: 'Position',
                                  helper_text: 'Controls the display order on the Home Page (ascending).'
          end
        end
      end
    end
  end
end
