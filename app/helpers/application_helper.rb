module ApplicationHelper
	def app_name
		"CIVIS"
  end

  def current_class?(test_path)
    request.fullpath == test_path ? 'active' : ''
  end
  
  def total_no_of_records_found(model, name, facets)
    if facets.present?
      return "#{model.facets.total_count} #{name} found" if model.facets.total_count > 1
      "#{model.facets.total_count} #{name.singularize} found"
    else
      return "#{model.length} #{name} found" if model.length > 1
      "#{model.length} #{name.singularize} found"
    end
  end
  
end
