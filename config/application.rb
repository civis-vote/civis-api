require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CivisApi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    config.action_mailer.delivery_method = :postmark

    config.active_job.queue_adapter = :sidekiq
    config.active_storage.queues.analysis = :default
    config.active_storage.queues.purge = :default

    config.autoload_paths << Rails.root.join("lib")
    config.eager_load_paths << Rails.root.join("lib")

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins Rails.application.config.allowed_cors_origins
        resource '*',
        methods: [:get, :post, :delete, :put, :patch, :options, :head],
        headers: :any,
        max_age: 600 
      end
    end

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