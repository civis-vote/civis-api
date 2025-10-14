module Queries
  module Department
    class Autocomplete < Queries::BaseQuery
      description "Get an autocomplete list of ministry"
      argument :q, String, required: false, default_value: nil
      type [Types::Objects::Department], null: false

      def resolve(q:)
        ::Department.search(q).approved.alphabetical
      end

      def self.authorized?(object, context)
        context[:current_user].present?
      end
    end
  end
end

