# frozen_string_literal: true

# Hatchbox deployment notification script
# Sends Slack notifications for deployment lifecycle events.
#
# Usage: HATCHBOX_EVENT_TYPE=<event_type> ruby hatchbox_notification.rb
# event_type: "pre_build", "post_deploy", or "failed_deploy"

require_relative "config"
require_relative "event_types"

module Hatchbox
  module Notification
    def self.run(event_type)
      return unless Config.deployment_alerts?

      missing_values = Config.missing_config_values
      unless missing_values.empty?
        EventTypes.send_notification(EventTypes.build_config_unavailable_payload(missing_values))
        exit 0
      end

      payload = EventTypes.build_payload(event_type)
      EventTypes.send_notification(payload)
    end
  end
end

Hatchbox::Notification.run(ENV.fetch('HATCHBOX_EVENT_TYPE', ''))
