module Types
  module Objects
    module BlogPost
      class Base < BaseObject
        graphql_name "BaseBlogPostType"
        field :id,	Int, "ID of the blog post", null: false
        field :title,	String, "Title of the blog post", null: false
        field :slug,	String, "URL slug of the blog post", null: true
        field :description,	String, "Short excerpt shown on blog cards", null: true
        field :content,	String, "HTML content of the blog post", null: true
        field :blog_category,	Types::Objects::BlogCategory::Base, nil, null: true
        field :featured_image,	Types::Objects::AttachmentType, nil, null: true do
          argument :resolution, String, required: false, default_value: nil
        end
        field :created_by,	Types::Objects::User::Base, "Author of the blog post", null: true
        field :created_by_name,	String, "Full name of the author", null: true
        field :published_at,	Types::Objects::DateTime, nil, null: true
        field :created_at,					Types::Objects::DateTime, nil, null: false
        field :updated_at,					Types::Objects::DateTime, nil, null: false

        def content
          object.content.to_s
        end

        def featured_image(resolution:)
          attachment_with_resolution(:featured_image, resolution)
        end

        def created_by_name
          object.created_by_full_name
        end
      end
    end
  end
end
