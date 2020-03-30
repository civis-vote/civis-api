require "image_processing/mini_magick"

class ImageUploader < Shrine
  # plugins and uploading logic
  
  plugin :determine_mime_type

  if Rails.env.production?
	  host = "https://cdn.civis.vote/"
	elsif Rails.env.staging?
	  host = "https://cdn-staging.civis.vote/"
	else
	  host = "http:localhost:3000"
	end

  plugin :derivation_endpoint, upload: true, upload_storage: :store, prefix: "derivations/image" , upload_location: -> { 
  	["derivatives", File.basename(source.id, ".*"), [name, *args].join("-")].join("/")
	}, host: host

  derivation :resize do |file, width, height|
    ImageProcessing::MiniMagick
      .source(file)
      .resize_to_limit!(width.to_i, height.to_i)
  end
end