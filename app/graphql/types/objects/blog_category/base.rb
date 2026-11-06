module Types
	module Objects
		module BlogCategory
			class Base < BaseObject
				graphql_name "BlogCategoryBase"
				field :id,							Int, "ID of the blog category", null: false
				field :name,						String, "Name of the blog category", null: false
				field :icon,						Types::Objects::AttachmentType, "Small icon shown next to the category name", null: true do
					argument :resolution, String, required: false, default_value: nil
				end

				def icon(resolution:)
					attachment_with_resolution(:icon, resolution)
				end
			end
		end
	end
end
