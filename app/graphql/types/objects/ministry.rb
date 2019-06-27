module Types
	module Objects
		class Ministry < BaseObject
			field :id,									Int, "ID of the location", null: false
			field :category,						Types::Objects::Constant, "Category of the ministry", null: true
			field :cover_photo,					Types::Objects::Attachment, nil, null: false
			field :level,								Types::Enums::MinistryLevels, nil, null: false
			field :logo,								Types::Objects::Attachment, nil, null: false
			field :name,								String, nil, null: false
			field :poc_email_primary,		String, nil, null: false
			field :poc_email_secondary,	String, nil, null: false
		end
	end
end