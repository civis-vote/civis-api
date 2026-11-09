module Queries
  module BlogPost
    class List < Queries::BaseQuery
      description "Get a list of published blog posts"
      argument :blog_category_filter,	Int,	required: false, default_value: nil
      argument :page,	Int,	required: false, default_value: 1
      argument :per_page,	Int,	required: false, default_value: 20
      argument :sort,	Types::Enums::BlogPostSorts,	required: false, default_value: nil
      argument :sort_direction,		Types::Enums::SortDirections,	required: false, default_value: nil
      argument :search_filter,			String,	required: false, default_value: nil
      argument :year_filter,	Int,	required: false, default_value: nil

      type Types::Objects::BlogPost::List, null: true

      def resolve(blog_category_filter:, year_filter:, search_filter:, per_page:, page:, sort:, sort_direction:)
        scope = ::BlogPost.published.includes(:created_by, :blog_category).with_attached_featured_image
                          .with_rich_text_content
                          .search(search_filter)
                          .blog_category_filter(blog_category_filter)
                          .year_filter(year_filter)
        scope = sort ? scope.sort_records(sort, sort_direction) : scope.order(published_at: :desc)
        scope.list(per_page, page)
      end
    end
  end
end
