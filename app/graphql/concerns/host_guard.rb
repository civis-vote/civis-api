# Restricts a GraphQL resolver to a set of allowed domains, checked against the
# request's Origin header. A listed domain matches itself and any subdomain.
#
#   include HostGuard
#   host_guard 'civis.vote'                                        # civis.vote + *.civis.vote
#   host_guard 'civis.vote', throttle: { limit: 5, period: 1.minute }
#
# `throttle` registers a per-IP Rack::Attack limit on the resolver's field. The
# field name is derived from the class name (Mutations::ContactForm::Submit ->
# contactFormSubmit).
#
# A resolver that defines its own instance-level `authorized?` without calling
# `super` will bypass the origin check.
module HostGuard
  extend ActiveSupport::Concern

  GRAPHQL_PATH = '/graphql'.freeze

  included do
    class_attribute :host_guard_domains, instance_accessor: false, default: [].freeze
  end

  class_methods do
    def host_guard(*domains, throttle: nil)
      self.host_guard_domains = domains.flatten.filter_map do |domain|
        domain.to_s.strip.downcase.sub(%r{\Ahttps?://}, '').sub(%r{/.*\z}, '').sub(/:\d+\z/, '').presence
      end.freeze
      register_throttle(throttle) if throttle
    end

    def valid_host?(context)
      host = URI.parse(context[:request]&.origin.to_s).host.to_s.downcase
      return false if host.blank?

      host_guard_domains.any? { |domain| host == domain || host.end_with?(".#{domain}") }
    rescue URI::InvalidURIError
      false
    end

    def authorized?(object, context)
      return super if valid_host?(context)

      raise GraphQL::ExecutionError, 'Unauthorized: Invalid host'
    end

    private

    def register_throttle(throttle)
      return unless defined?(Rack::Attack)

      field_name = name.split('::').drop(1).join.underscore.camelize(:lower)
      return if field_name.blank?

      Rack::Attack.throttle("host_guard_#{field_name}/ip", limit: throttle.fetch(:limit), period: throttle.fetch(:period)) do |req|
        next unless req.post? && req.path == GRAPHQL_PATH

        body = req.body.read
        req.body.rewind

        req.ip if body.match?(/\b#{Regexp.escape(field_name)}\b/)
      end
    end
  end

  def authorized?(**inputs)
    return super if self.class.valid_host?(context)

    raise GraphQL::ExecutionError, 'Unauthorized: Invalid host'
  end
end
