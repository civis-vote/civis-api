# Restricts a GraphQL resolver to a set of allowed domains, checked against the
# request's Origin header. A listed domain matches itself and any subdomain.
#
#   include HostGuard
#   host_guard 'civis.vote'                                        # civis.vote + *.civis.vote
#
# A resolver that defines its own instance-level `authorized?` without calling
# `super` will bypass the origin check.
module HostGuard
  extend ActiveSupport::Concern

  included do
    class_attribute :host_guard_domains, instance_accessor: false, default: [].freeze
  end

  class_methods do
    def host_guard(*domains)
      self.host_guard_domains = domains.flatten.filter_map do |domain|
        domain.to_s.strip.downcase.sub(%r{\Ahttps?://}, '').sub(%r{/.*\z}, '').sub(/:\d+\z/, '').presence
      end.freeze
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
  end

  def authorized?(**inputs)
    return super if self.class.valid_host?(context)

    raise GraphQL::ExecutionError, 'Unauthorized: Invalid host'
  end
end
