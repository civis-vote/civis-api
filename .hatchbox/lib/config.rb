# frozen_string_literal: true

module Hatchbox
  module Config
    CM_DEPLOYMENT_SLACK_WEBHOOK_URL = nil # Set SLACK_WEBHOOK_URL in Hatchbox env vars — do not commit real webhook URLs

    def self.app_name
      ENV.fetch('APP_NAME', nil)
    end

    def self.env_name
      ENV.fetch('RAILS_ENV', 'unknown').capitalize
    end

    def self.server_name
      ENV.fetch('HATCHBOX_SERVER_NAME', nil)
    end

    def self.hatchbox_app_name
      ENV.fetch('DIR', '').split('/').last
    end

    def self.hatchbox_app_id
      ENV.fetch('HATCHBOX_APP_ID', nil)
    end

    def self.hatchbox_logs_url
      "https://app.hatchbox.io/apps/#{hatchbox_app_id}/logs/#{ENV.fetch('LOG_ID', '')}"
    end

    def self.hatchbox_env_vars_url
      "https://hatchbox.io/apps/#{hatchbox_app_id}/env_vars"
    end

    def self.app_url
      ENV.fetch('APP_URL', nil)
    end

    def self.slack_webhook
      ENV.fetch('SLACK_WEBHOOK_URL', CM_DEPLOYMENT_SLACK_WEBHOOK_URL).to_s
    end

    def self.deployment_alerts?
      ENV.fetch('DEPLOYMENT_ALERTS', 'true') != 'false'
    end

    def self.missing_config_values
      {
        'APP_NAME' => app_name,
        'APP_URL' => app_url,
        'SLACK_WEBHOOK_URL' => slack_webhook
      }.select { |_name, value| value.to_s.strip.empty? }.keys
    end
  end
end
