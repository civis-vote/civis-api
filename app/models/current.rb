class Current < ActiveSupport::CurrentAttributes
  attribute :user, :request_id, :user_agent, :ip_address, :request_params

  resets { Time.zone = nil }
end
