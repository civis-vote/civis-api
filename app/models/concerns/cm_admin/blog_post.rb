module CmAdmin
  module BlogPost
    extend ActiveSupport::Concern

    STATUS_TAG_COLORS = { draft: 'cm-badge-cyan', published: 'cm-badge-green',
                          archived: 'cm-badge-gray' }.freeze

    included do
      cm_admin do
        actions only: []
        icon_name 'fas fa-newspaper'

        cm_index do
          page_title 'Blog Posts'

          filter %i[title description], :search, placeholder: 'Search'
          filter :status, :multi_select, active_by_default: true
          filter :blog_category_id, :single_select, helper_method: :select_options_for_blog_category,
                                                   placeholder: 'Blog Category'

          column :id
          column :title
          column :slug
          column :blog_category_name, header: 'Category'
          column :status, field_type: :badge, badge_class: STATUS_TAG_COLORS
          column :published_at, field_type: :date, format: '%d %b, %Y'
          column :created_by_full_name, header: 'Author'
          column :created_at, field_type: :date, format: '%d %b, %Y'
        end

        cm_show page_title: :title do
          custom_action name: 'publish', route_type: 'member', verb: 'patch', path: ':id/publish',
                        icon_name: 'fa-solid fa-check', display_type: :modal,
                        modal_configuration: {
                          title: 'Publish Blog Post',
                          description: 'Are you sure you want to publish this blog post?',
                          confirmation_text: 'Publish'
                        },
                        display_if: ->(post) { post.draft? || post.archived? } do
            post = ::BlogPost.find(params[:id])
            post.publish
            post
          end

          custom_action name: 'archive', route_type: 'member', verb: 'patch', path: ':id/archive',
                        icon_name: 'fa-solid fa-box-archive', display_type: :modal,
                        modal_configuration: {
                          title: 'Archive Blog Post',
                          description: 'Are you sure you want to archive this blog post?',
                          confirmation_text: 'Archive'
                        },
                        display_if: lambda(&:published?) do
            post = ::BlogPost.find(params[:id])
            post.archive
            post
          end

          tab :profile, '' do
            cm_section 'Blog Post details' do
              field :title
              field :slug
              field :description
              field :status, field_type: :badge, badge_class: STATUS_TAG_COLORS
              field :content, field_type: :rich_text
              field :featured_image, field_type: :image, display_if: ->(post) { post.featured_image.attached? }
              field :blog_category_name, label: 'Category'
            end
            cm_section 'Log Details' do
              field :created_by_full_name, label: 'Author'
              field :created_at, field_type: :date, format: '%d %b, %Y'
              field :updated_by_full_name, label: 'Updated By'
              field :updated_at, field_type: :date, format: '%d %b, %Y', label: 'Last Updated At'
              field :published_at, field_type: :datetime
              field :archived_at, field_type: :datetime
            end
          end
        end

        cm_new page_title: 'Add Blog Post', page_description: 'Enter all details to add Blog Post' do
          cm_section 'Details' do
            form_field :title
            form_field :description, input_type: :text, helper_text: 'Short excerpt shown on blog cards'
            form_field :content, input_type: :rich_text
            form_field :featured_image, input_type: :single_file_upload
            form_field :blog_category_id, input_type: :single_select, label: 'Category',
                                          helper_method: :select_options_for_blog_category,
                                          can_create_new_entity: { model: 'BlogCategory' }
          end
        end

        cm_edit page_title: 'Edit Blog Post', page_description: 'Enter all details to edit Blog Post' do
          cm_section 'Details' do
            form_field :title
            form_field :slug
            form_field :description, input_type: :text, helper_text: 'Short excerpt shown on blog cards'
            form_field :content, input_type: :rich_text
            form_field :featured_image, input_type: :single_file_upload
            form_field :blog_category_id, input_type: :single_select, label: 'Category',
                                          helper_method: :select_options_for_blog_category,
                                          can_create_new_entity: { model: 'BlogCategory' }
          end
        end
      end
    end
  end
end
