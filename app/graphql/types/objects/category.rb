module Types
	module Objects
		class Category < BaseObject
			field :id,					Int, 			nil, null: false
			field :name,				String, 	nil, null: false
			field :cover_photo,					Types::Objects::Attachment, nil, null: true do 
				argument :resolution, String, required: false, default_value: nil
			end

			def cover_photo(resolution:)
				object.resize(resolution, "cover_photo")
			end
			
		end
	end
end