module NavigationHelper
  def ensure_navigation
  	request_url = request.path_info
  	@navigation ||= [ { title: "Dashboard", url: root_path } ]
  end

  def navigation_add(title, url)
    ensure_navigation << { title: title, url: url }
  end

  def render_navigation
    render partial: "layouts/navigation", locals: { nav: ensure_navigation }
  end
end
