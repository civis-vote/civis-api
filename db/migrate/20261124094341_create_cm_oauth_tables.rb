class CreateCmOauthTables < ActiveRecord::Migration[8.1]
  def change
    create_table :cm_oauth_clients do |t|
      t.string :client_id, null: false, index: {unique: true}
      t.string :client_name
      t.jsonb :redirect_uris, null: false, default: []
      t.datetime :metadata_fetched_at
      t.datetime :metadata_expires_at

      t.timestamps
    end

    create_table :cm_oauth_grants do |t|
      t.references :cm_oauth_client, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: {on_delete: :cascade}
      t.string :code_digest, null: false, index: {unique: true}
      t.string :redirect_uri, null: false
      t.string :code_challenge, null: false
      t.string :resource, null: false
      t.string :scope
      t.datetime :expires_at, null: false
      t.datetime :used_at

      t.timestamps
    end

    create_table :cm_oauth_tokens do |t|
      t.references :cm_oauth_client, null: false, foreign_key: true
      t.references :cm_oauth_grant, null: false, foreign_key: {on_delete: :cascade}
      t.references :user, null: false, foreign_key: {on_delete: :cascade}
      t.string :access_token_digest, null: false, index: {unique: true}
      t.string :refresh_token_digest, null: false, index: {unique: true}
      t.string :resource, null: false
      t.string :scope
      t.datetime :access_expires_at, null: false
      t.datetime :refresh_expires_at, null: false
      t.datetime :revoked_at

      t.timestamps
    end
  end
end
