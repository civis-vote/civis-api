# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

module Hatchbox
  module EventTypes
    EVENTS = {
      'pre_build' => {
        title: 'Deployment Started',
        emoji: 'hourglass_flowing_sand',
        message: 'has started to deploy via Hatchbox.',
        button_text: 'View on Hatchbox',
        button_style: nil
      },
      'post_deploy' => {
        title: 'Deployment Complete',
        emoji: 'done',
        message: 'has been deployed successfully via Hatchbox.',
        button_text: 'View on Hatchbox',
        button_style: nil
      },
      'failed_deploy' => {
        title: 'Deployment Failed',
        emoji: 'x',
        message: 'has failed to deploy via Hatchbox.',
        button_text: 'View on Hatchbox',
        button_style: 'danger'
      }
    }.freeze

    def self.build_payload(event_type)
      event = EVENTS[event_type]
      return nil unless event

      {
        text: "#{Config.app_name} #{event[:message]}",
        blocks: [
          { type: 'header', text: { type: 'plain_text', text: event[:title], emoji: true } },
          { type: 'rich_text', elements: [
            { type: 'rich_text_section', elements: [
              { type: 'emoji', name: event[:emoji] },
              { type: 'text', text: " #{Config.app_name} #{event[:message]}" }
            ] }
          ] },
          { type: 'actions', elements: build_buttons(event) }
        ]
      }
    end

    def self.build_config_unavailable_payload(missing_values)
      missing_list = missing_values.map { |name| "• `#{name}`" }.join("\n")

      text = ":warning: Deployment notification config for *#{Config.hatchbox_app_name}* is not available. " \
             "These values need to be updated for this environment:\n#{missing_list}\n"
      text += ":package: Environment: *#{Config.env_name}*\n"
      text += ":desktop_computer: Server: *#{Config.server_name}*\n"
      text += 'Set them under Environment Variables in the Hatchbox dashboard.'

      {
        blocks: [
          { type: 'header', text: { type: 'plain_text', text: 'Deployment Notification Config Not Available', emoji: true } },
          { type: 'section', text: { type: 'mrkdwn', text: text } },
          { type: 'actions', elements: [
            { type: 'button',
              text: { type: 'plain_text', text: 'Environment Variables' },
              url: Config.hatchbox_env_vars_url,
              style: 'primary' }
          ] }
        ]
      }
    end

    def self.build_buttons(event)
      buttons = []

      button = {
        type: 'button',
        text: { type: 'plain_text', text: event[:button_text] },
        url: Config.hatchbox_logs_url
      }
      button[:style] = event[:button_style] if event[:button_style]
      buttons << button

      app_url = Config.app_url
      if app_url && !app_url.empty?
        buttons << {
          type: 'button',
          text: { type: 'plain_text', text: 'View Application' },
          url: app_url,
          style: 'primary'
        }
      end

      buttons
    end

    def self.send_notification(payload)
      return false unless payload

      webhook = Config.slack_webhook
      if webhook.empty?
        warn 'Error: SLACK_WEBHOOK_URL is not set'
        return false
      end

      uri = URI.parse(webhook)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'
      http.open_timeout = 5
      http.read_timeout = 10

      request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
      request.body = JSON.generate(payload)

      response = http.request(request)

      response.code.to_i.between?(200, 299)
    rescue StandardError
      false
    end
  end
end
