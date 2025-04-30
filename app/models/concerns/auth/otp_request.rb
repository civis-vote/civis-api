module Auth
  module OtpRequest
    extend ActiveSupport::Concern

    included do
      scope :expired, lambda {
        where(status: %i[resent time_out cancelled]).or(OtpRequest.where(status: :created).where('created_at < ?', DateTime.now - 15.minutes))
      }
      scope :timed_out, -> { where(status: :created).where('created_at < ?', DateTime.now - 15.minutes) }
      scope :unverified, -> { where.not(status: :verified) }
      scope :active, -> { where(status: :created).where('created_at > ?', DateTime.now - 15.minutes) }

      scope :status_filter, lambda { |status|
        return nil unless status.present?

        where(status: status)
      }
    end
  end
end
