module Types
	module Objects
		class Ministry < BaseObject
			field :id,									Int, "ID of the location", null: false
			field :category,						Types::Objects::Category, "Category of the ministry", null: true
			field :level,								Types::Enums::MinistryLevels, nil, null: false
			field :logo,								Types::Objects::Attachment, nil, null: true do
				argument :resolution, String, required: false, default_value: nil
			end
			field :cover_photo,					Types::Objects::Attachment, nil, null: true do 
				argument :resolution, String, required: false, default_value: nil
			end

			field :name,								String, nil, null: false
			field :poc_email_primary,		String, nil, null: false
			field :poc_email_secondary,	String, nil, null: false

			def logo(resolution:)
				object.resize(resolution, "logo")
			end
			
			def cover_photo(resolution:)
				object.resize(resolution, "cover_photo")
			end

		end
	end
end