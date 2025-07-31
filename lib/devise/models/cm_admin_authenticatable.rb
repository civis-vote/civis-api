require Rails.root.join('lib/devise/strategies/cm_admin_authenticatable')

module Devise
  module Models
    module CmAdminAuthenticatable
      extend ActiveSupport::Concern
    end
  end
end
