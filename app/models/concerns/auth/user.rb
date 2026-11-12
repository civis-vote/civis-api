module Auth
  module User
    extend ActiveSupport::Concern
    # The Following is required for access_token creation
    def generate_token(type: 'access')
      exp = type == 'access' ? (Time.now + 2.hours).to_i : (Time.now + 6.month).to_i
      payload = { user_id: id, iat: Time.now.to_i, exp: }
      secret_token = Rails.application.credentials.dig(:auth, "#{type}_token_secret".to_sym)
      token = JWT.encode(payload, secret_token)
      api_tokens.create!(token:)
      token
    end

    def create_otp_request(status = :cancelled, delivery_channel: :email)
      otp = rand(100_000..999_999)
      otp_request = otp_requests.new(otp:, status: :created, delivery_channel:)
      if otp_request.save
        previous_requests = otp_requests.where.not(id: otp_request.id)
        previous_requests.timed_out.update_all(status: :time_out, expired_at: DateTime.now)
        previous_requests.active.update_all(status:, expired_at: DateTime.now)
      end
      otp_request
    end

    def verify_otp(otp)
      otp_requests.timed_out.update_all(status: :time_out, expired_at: DateTime.now)
      active_otp = otp_requests.active.last
      return false unless active_otp.present? && active_otp.otp.to_s == otp

      active_otp.update!(status: :verified, verified_at: DateTime.now)
      mark_channel_verified(active_otp.delivery_channel)
      otp_requests.active.update_all(status: :cancelled, expired_at: DateTime.now) if otp_requests.active.present?
      true
    end

    def mark_channel_verified(channel)
      column = channel.to_s == 'phone' ? :phone_verified_at : :confirmed_at
      update_columns(column => Time.current, updated_at: Time.current) if self[column].blank?
    end

    def can_access_admin_panel?
      %w[admin moderator organisation_employee super_admin].include?(cm_role&.name&.parameterize&.underscore.to_s)
    end

    def role?(role_name)
      cm_role&.name&.parameterize&.underscore.to_s == role_name
    end
  end
end
