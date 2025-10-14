module Types
  module Objects
    class ThemeList < BaseObject
      graphql_name "ListThemeType"

      field :data, [Types::Objects::Theme], nil, null: true
      field :paging, Types::Objects::Paging, nil, null: false
    end
  end
end
