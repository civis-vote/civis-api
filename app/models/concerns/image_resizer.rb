module ImageResizer
  def resize(resolution, image)
  	return nil unless send(image).attached?
  	if resolution.present?
  		send(image).variant(resize: resolution)
  	else
  		send(image)
  	end
  end
end