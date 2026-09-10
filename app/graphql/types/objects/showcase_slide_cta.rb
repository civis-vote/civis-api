module Types
  module Objects
    class ShowcaseSlideCta < BaseObject
      graphql_name "ShowcaseSlideCta"
      description "Call-to-action for a showcase slide"

      field :label, String, null: false
      field :url, String, null: false
    end
  end
end
