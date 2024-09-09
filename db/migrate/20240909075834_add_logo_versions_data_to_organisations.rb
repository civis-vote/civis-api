class AddLogoVersionsDataToOrganisations < ActiveRecord::Migration[7.1]
  def change
    add_column :organisations, :logo_versions_data, :jsonb
  end
end
