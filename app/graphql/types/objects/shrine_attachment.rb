module Types
	module Objects
		class ShrineAttachment < BaseObject
			field :id,					String, 	nil, null: false
			field :filename,		String, 	nil, null: false
			field :url,					String, 	nil, null: false

			def id
        object.class == Hash ? object["id"] : object.id 
			end

			def filename
        object.class == Hash ? object["filename"] : object.metadata["filename"]
			end

			def url
				object.class == Hash ? object["url"] : object.url
			end
		end
	end
end