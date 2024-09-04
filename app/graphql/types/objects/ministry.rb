module Types
	 module Objects
 		 class Ministry < BaseObject
  			 field :id,	Int, 'ID of the location', null: false
  			 field :category,	Types::Objects::Category, 'Category of the ministry', null: true
  			 field :level,	Types::Enums::MinistryLevels, nil, null: false
  			 field :logo,	Types::Objects::ShrineAttachment, nil, null: true do
   				 argument :resolution, String, required: false, default_value: nil
   			end
  			 field :name,	String, nil, null: false
				 field :hindi_name,	String, nil, null: false
				 field :odia_name,	String, nil, null: false
  			 field :location_id, Int, nil, null: false
  			 field :poc_email_primary,	String, nil, null: false
  			 field :poc_email_secondary,	String, nil, null: false

  			 def logo(resolution:)
   				 object.shrine_resize(resolution, 'logo')
   			 end

  			 def hindi_name
   				 object.name_hindi if object.name_hindi.present?
   			 end

  			 def odia_name
   				 object.name_odia if object.name_odia.present?
   			 end
  		end
 	end
end
