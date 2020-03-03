class WebpackHelper

  class << self
    def my_gem_js(path)
      File.join(Gem.loaded_specs["my_gem"].full_gem_path, "app/assets/javascripts/my_gem/", path)
    end

    def my_gem_css(path)
      File.join(Gem.loaded_specs["my_gem"].full_gem_path, "app/assets/stylesheets/my_gem/", path)
    end
  end

end
