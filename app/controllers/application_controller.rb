class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  add_flash_types :flash_info, :flash_success_info
  include ActiveStorage::SetCurrent

  def health
    User.exists?
    render json: { message: 'Health Check OK' }, status: :ok
  end
end
