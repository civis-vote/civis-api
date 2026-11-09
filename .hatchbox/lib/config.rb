# frozen_string_literal: true

module Hatchbox
  module Config
    def self.app_name
      ENV.fetch('APP_NAME', nil)
    end

    def self.hatchbox_app_id
      ENV.fetch('HATCHBOX_APP_ID', nil)
    end

    def self.hatchbox_logs_url
      "https://app.hatchbox.io/apps/#{hatchbox_app_id}/logs/#{ENV.fetch('LOG_ID', '')}"
    end

    def self.app_url
      ENV.fetch('APP_URL', nil)
    end

    def self.slack_webhook
      ENV.fetch('SLACK_WEBHOOK_URL', nil)
    end

    def self.deployment_alerts?
      ENV.fetch('DEPLOYMENT_ALERTS', 'true') != 'false'
    end
  end
end
