module CmAdmin
  class ApplicationController < ActionController::Base
    include Authentication
    include ActiveStorage::SetCurrent
    before_action :authenticate_user!
    before_action :sample_requests_for_scout
    before_action :set_paper_trail_whodunnit

    layout 'cm_admin'
    helper CmAdmin::ViewHelpers

    def append_info_to_payload(payload)
      super
      payload[:user_id] = Current.user&.id
    end

    private

    def sample_requests_for_scout
      # Sample rate should range from 0-1:
      # * 0: captures no requests
      # * 0.5: captures 50% of requests
      # * 1: captures all requests
      sample_rate = Rails.configuration.x.project_settings.scout_sample_rate

      return unless rand > sample_rate

      Rails.logger.debug("[Scout] Ignoring request: #{request.original_url}")
      ScoutApm::Transaction.ignore!
    end
  end
end
