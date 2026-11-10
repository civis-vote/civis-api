module Types
  module Objects
    module BlogCategory
      class Base < BaseObject
        graphql_name "BaseBlogCategoryType"
        field :id, Int, "ID of the blog category", null: false
        field :name, String, "Name of the blog category", null: false
        field :icon_name, String, "Font Awesome icon class shown next to the category name", null: true
        field :hex_code, String, "Hex colour for the category tag", null: true
      end
    end
  end
end
