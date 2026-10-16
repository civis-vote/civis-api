module Types
  module Inputs
    module CurrentUser
      class UpdatePreferences < Types::BaseInputObject
        graphql_name "CurrentUserUpdatePreferencesInput"
        argument :area_of_impact_ids, [Integer], nil, required: false
        argument :theme_ids, [Integer], nil, required: false
      end
    end
  end
end
