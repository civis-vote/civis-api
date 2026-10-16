class CreateCtPageViews < ActiveRecord::Migration[8.1]
  def up
    enable_extension 'citext' unless extension_enabled?('citext')

    create_table :ct_page_views do |t|
      t.references :owner, polymorphic: true, null: false
      t.citext :name, null: false
      t.string :ar_model_name, null: false, index: true
      t.string :associated_ar_model_name, index: true, default: '', null: false
      t.string :visible_columns, array: true, default: []
      t.string :hidden_columns, array: true, default: []
      t.boolean :is_default, default: false, null: false
      t.integer :view_type, default: 0
      t.integer :records_per_page, default: 20
      t.jsonb :filter_params, default: {}
      t.json :sort_params, default: {}

      t.timestamps
    end

    migrate_index_preferences

    add_index :ct_page_views,
              %i[owner_type owner_id ar_model_name associated_ar_model_name],
              unique: true,
              where: 'is_default = true',
              name: :index_ct_page_views_on_unique_default

    drop_table :cm_index_preferences if table_exists?(:cm_index_preferences)
  end

  def down
    drop_table :ct_page_views if table_exists?(:ct_page_views)

    create_table :cm_index_preferences do |t|
      t.bigint :user_id, null: false, index: true
      t.string :ar_model_name, null: false, index: true
      t.string :associated_ar_model_name, index: true
      t.string :visible_columns, array: true, default: []
      t.string :hidden_columns, array: true, default: []
      t.integer :records_per_page, default: 20

      t.timestamps
    end
  end

  private

  # Carry saved cm-admin index preferences into ct_page_views so existing
  # admin column views survive the 8.2.8 upgrade. The first row per
  # user/model pair becomes the default view.
  def migrate_index_preferences
    return unless table_exists?(:cm_index_preferences)

    execute <<~SQL.squish
      INSERT INTO ct_page_views
        (owner_type, owner_id, name, ar_model_name, associated_ar_model_name,
         visible_columns, hidden_columns, is_default, view_type,
         records_per_page, created_at, updated_at)
      SELECT 'User', user_id,
             CONCAT(ar_model_name, ' view'),
             ar_model_name,
             COALESCE(associated_ar_model_name, ''),
             visible_columns, hidden_columns,
             ROW_NUMBER() OVER (
               PARTITION BY user_id, ar_model_name, COALESCE(associated_ar_model_name, '')
               ORDER BY created_at
             ) = 1,
             0, records_per_page, created_at, updated_at
      FROM cm_index_preferences
    SQL
  end
end
