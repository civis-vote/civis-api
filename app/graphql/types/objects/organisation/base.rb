module Types
  module Objects
    module Organisation
      class Base < BaseObject
        graphql_name "OrganisationType"

        field :id, Int, "ID of the organisation", null: false
        field :name, String, "Name of the organisation", null: false
        field :logo,	Types::Objects::AttachmentType, nil, null: true do
          argument :resolution, String, required: false, default_value: nil
        end
        field :employee_count, Int, "Number of employees in the organisation", null: false
        field :official_url, String, "Official URL of the organisation", null: true
        field :created_at, GraphQL::Types::ISO8601DateTime, "Date and time when the organisation was created", null: false
        field :updated_at, GraphQL::Types::ISO8601DateTime, "Date and time when the organisation was last updated", null: false

        def employee_count
          object.users_count
        end

        def logo(resolution:)
          attachment_with_resolution(:logo, resolution)
        end
      end
    end
  end
end
