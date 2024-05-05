require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CivisApi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    config.action_mailer.delivery_method = :postmark

    config.active_job.queue_adapter = :sidekiq
    config.active_storage.queues.analysis = :default
    config.active_storage.queues.purge = :default

    config.autoload_paths << Rails.root.join("lib")
    config.eager_load_paths << Rails.root.join("lib")

    config.after_initialize do
      default_allowed_attributes = Rails::HTML5::Sanitizer.safe_list_sanitizer.allowed_attributes + ActionText::Attachment::ATTRIBUTES.to_set
      custom_allowed_attributes = Set.new(%w[controls data-controller role style frameborder])
      ActionText::ContentHelper.allowed_attributes = (default_allowed_attributes + custom_allowed_attributes).freeze

      default_allowed_tags = Rails::HTML5::Sanitizer.safe_list_sanitizer.allowed_tags + Set.new([ActionText::Attachment.tag_name, "figure", "figcaption"])
      custom_allowed_tags = Set.new(%w[iframe])
      ActionText::ContentHelper.allowed_tags = (default_allowed_tags + custom_allowed_tags).freeze
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    #Referrer Policy
    Rails.application.configure do
      config.action_dispatch.default_headers = {
        'Referrer-Policy' => 'strict-origin-when-cross-origin'
      }
    end

    #X-Content-Type-Options
    Rails.application.configure do 
      config.action_dispatch.default_headers = { 'X-Content-Type-Options' => 'nosniff' } 
    end

    #X-Frame-Options 
    Rails.application.configure do 
      config.action_dispatch.default_headers = { 'X-Frame-Options' => 'SAMEORIGIN' } 
    end

    #X-XSS-Protection
    Rails.application.configure do 
      config.action_dispatch.default_headers = { 'X-XSS-Protection' => '1; mode=block' } 
    end
  end
end
