module Types
	module Objects
		class ShrineAttachment < BaseObject
			field :id,					String, 	nil, null: false
			field :filename,		String, 	nil, null: false
			field :url,					String, 	nil, null: false

			def id
        object.id
			end

			def filename
        object.metadata["filename"].to_s
			end

			def url
				object.url
			end
		end
	end
end