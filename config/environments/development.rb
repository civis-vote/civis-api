Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  # if Rails.root.join('tmp/caching-dev.txt').exist?
  #   config.action_controller.perform_caching = true

  #   config.cache_store = :memory_store
  #   config.public_file_server.headers = {
  #     'Cache-Control' => "public, max-age=#{2.days.seconds.to_i}"
  #   }
  # else
  config.action_controller.perform_caching = true

  # config.cache_store = :memory_store
  # end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  config.active_job.queue_adapter = :sidekiq
  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }

  config.client_url = { host: "localhost", port:3000, protocol: :http }
  config.host_url = { host: "localhost", port:3000, protocol: :http }

  # Raises error for missing translations.
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address:              "smtp.postmarkapp.com",
    port:                 587,
    domain:               "civis.vote",
    user_name:            Rails.application.credentials.dig(:postmark, :api_key),
    password:             Rails.application.credentials.dig(:postmark, :api_key),
    authentication:       "plain",
  enable_starttls_auto: true  }

  Rails.application.routes.default_url_options[:host] = "localhost:3000"
  Rails.application.config.allowed_cors_origins = ['localhost:[0-9]+', 'https?://127.0.0.1:[0-9]+']
end
