module Types
	 module Inputs
 		 module Ministry
  			 class Create < Types::BaseInputObject
   					argument :category_id,	Int,	nil,	required: true
   					argument :level,	Types::Enums::MinistryLevels,	nil,	required: true
   					argument :logo_file,	Types::Inputs::Attachment,	nil,	required: true
   					argument :name,	String,	nil,	required: true
   					argument :poc_email_primary,	String,	nil,	required: true
   					argument :poc_email_secondary,	String,	nil,	required: false
   			end
  		end
 	end
end
