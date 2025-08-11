module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :check_current_user
  end

  private

  def check_current_user
    Current.request_params = request.params
    return unless current_user

    Current.user = current_user
  end
end
