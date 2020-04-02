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
  		array_resolution = resolution.split('X')
      if send("#{image}_versions_data").present?
        image_versions_data = nil
        send("#{image}_versions_data").each do |versions_data|
          image_versions_data = versions_data if versions_data["width"] == "#{array_resolution[0].to_i}" && versions_data["height"] == "#{array_resolution[1].to_i}"
        end
      end
      if image_versions_data.present?
        return image_versions_data
      else
  		  uploaded_file = send(image).derivation(:resize, array_resolution[0].to_i, array_resolution[1].to_i).upload
        h = {width: "#{array_resolution[0].to_i}", height: "#{array_resolution[1].to_i}", url: "#{uploaded_file.url}", id: send(image).id, filename: "#{send(image).metadata['filename']}_#{resolution}" }
        if send("#{image}_versions_data").present?
          new_array = send("#{image}_versions_data") << h
          self.update("#{image}_versions_data": new_array)
        else
          a = []
          a << h
          self.update("#{image}_versions_data": a)
        end
        return h
      end
  	else
  		send(image)
  	end
  end
end