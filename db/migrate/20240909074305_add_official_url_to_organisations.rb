class AddOfficialUrlToOrganisations < ActiveRecord::Migration[7.1]
  def change
    add_column :organisations, :official_url, :string
  end
end
