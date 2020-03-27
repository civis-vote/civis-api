module ImageResizer
  def resize(resolution, image)
  	return nil unless send(image).present?
  	if resolution.present?
  		send(image).variant(resize: resolution)
  	else
  		send(image)
  	end
  end

  def shrine_resize(resolution, image)
  	return nil unless send(image).present?
  	if resolution.present?
  		array = resolution.split('X')
  		send(image).derivation(:resize, array[0].to_i, array[1].to_i).upload
  	else
  		send(image)
  	end
  end
end