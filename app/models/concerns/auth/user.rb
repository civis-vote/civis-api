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

    def create_otp_request(status = :cancelled)
      otp_requests.timed_out.update_all(status: :time_out, expired_at: DateTime.now)
      otp_requests.active.update_all(status:, expired_at: DateTime.now)
      otp = rand(100_000..999_999)
      otp_requests.create!(otp:, status: :created)
    end

    def verify_otp(otp)
      otp_requests.timed_out.update_all(status: :time_out, expired_at: DateTime.now)
      active_otp = otp_requests.active.last
      return false unless active_otp.present? && active_otp.otp.to_s == otp

      active_otp.update!(status: :verified, verified_at: DateTime.now)
      otp_requests.active.update_all(status: :cancelled, expired_at: DateTime.now) if otp_requests.active.present?
      true
    end

    def can_access_admin_panel?
      true
    end
  end
end
