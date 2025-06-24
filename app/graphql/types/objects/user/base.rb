module Types
  module Objects
    module User
      class Base < BaseObject
        field :id,	Integer,	nil, null: false
        field :best_rank,	Integer,	nil, null: true
        field :best_rank_type,	Types::Enums::UserBestRankTypes, nil, null: true
        field :city,	Types::Objects::Location,	"City where the user is registered from.", null: true
        field :city_rank,	Integer,	"City rank in the system", null: true
        field :first_name,	String,	nil, null: true
        field :points,	Integer,	nil, null: false
        field :profile_picture,	Types::Objects::AttachmentType, null: true do
          argument :resolution, String, required: false, default_value: nil
        end
        field :rank,	Integer,	"Overall rank in the system", null: true
        field :shared_responses,	Types::Connections::ConsultationResponse, nil, null: true do
          argument :sort,	Types::Enums::ConsultationResponseSorts,	required: false, default_value: nil
          argument :sort_direction, Types::Enums::SortDirections,	required: false, default_value: nil
        end
        field :state_rank,	Integer,	"State rank in the system", null: true

        def profile_picture(resolution: nil)
          width, height = resolution.split("x").map(&:to_i)
          attachment = object.public_send(:profile_picture)

          return unless attachment.attached?

          return attachment if width.blank? || height.blank?

          attachment.variant(resize_to_limit: [width, height]).processed
        end

        def shared_responses(sort:, sort_direction:)
          object.shared_responses.sort_records(sort, sort_direction)
        end
      end
    end
  end
end
