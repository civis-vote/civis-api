module Types
	module Objects
		module User
			class Base < BaseObject
				field :id,								Integer, 										nil, null: false
				field :best_rank,					Integer,										nil, null: true
				field :best_rank_type,		Types::Enums::UserBestRankTypes, nil, null: true
				field :city,							Types::Objects::Location, 	"City where the user is registered from.", null: true
				field :city_rank,					Integer,										"City rank in the system", null: false
				field :first_name, 				String, 										nil, null: false
				field :points,						Float,											nil, null: false
				field :profile_picture,		Types::Objects::Attachment, nil, null: false do
					argument :resolution, String, required: false, default_value: nil
				end
				field :rank,							Integer,										"Overall rank in the system", null: false
				field :state_rank,				Integer,										"State rank in the system", null: false

				def profile_picture(resolution:)
					object.resize(resolution, "profile_picture")
				end
			end
		end
	end
end