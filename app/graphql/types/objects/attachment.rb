module Types
	module Objects
		class Attachment < BaseObject
			field :id,					Int, 			nil, null: false
			field :filename,		String, 	nil, null: false
			field :url,					String, 	nil, null: false

			def id
				if object.class.eql?(ActiveStorage::Variant)
	        object.blob.id
	      else
	        object.id
	      end
			end

			def filename
				if object.class.eql?(ActiveStorage::Variant)
	        object.blob.filename.to_s + "-" + object.variation.transformations[:resize]
	      else
	        object.filename.to_s
	      end
			end

			def url
				if object.class.eql?(ActiveStorage::Variant)
	        Rails.application.routes.url_helpers.rails_representation_url(object)
	      else
	        Rails.application.routes.url_helpers.rails_blob_url(object)
	      end
			end
		end
	end
end