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
    config.action_mailer.postmark_settings = { api_token: Rails.application.credentials.dig(:postmark, :api_key) }

    config.x.project_settings.name = 'CIVIS'
    config.x.project_settings.slug = 'civis'
    config.x.project_settings.logo_url = 'https://civis-staging-api.s3.ap-south-1.amazonaws.com/civis_logo.png'
    config.x.project_settings.favicon_url = 'https://civis-staging-api.s3.ap-south-1.amazonaws.com/favicon.png'
    config.x.project_settings.scout_sample_rate = 0.5

    config.x.project_settings.default_from_email = "support@platform.civis.vote"

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
