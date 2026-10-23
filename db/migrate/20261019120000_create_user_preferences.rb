class CreateUserPreferences < ActiveRecord::Migration[8.1]
  def up
    create_table :user_preferences do |t|
      t.references :user, null: false, foreign_key: true
      t.references :preferable, polymorphic: true, null: false
      t.timestamps
    end

    add_index :user_preferences, %i[user_id preferable_type preferable_id],
              unique: true, name: :index_user_preferences_on_user_and_preferable

    migrate_theme_preferences
    migrate_area_of_impact_preferences

    drop_table :user_theme_preferences if table_exists?(:user_theme_preferences)
  end

  def down
    create_table :user_theme_preferences do |t|
      t.references :user, null: false, foreign_key: true
      t.references :theme, null: false, foreign_key: true
      t.timestamps
    end

    add_index :user_theme_preferences, %i[user_id theme_id], unique: true

    restore_theme_preferences
    restore_area_of_impact_preferences

    drop_table :user_preferences if table_exists?(:user_preferences)
  end

  private

  def area_of_impact_constant_type
    Constant.constant_types[:area_of_impact]
  end

  def migrate_theme_preferences
    return unless table_exists?(:user_theme_preferences)

    execute <<~SQL.squish
      INSERT INTO user_preferences (user_id, preferable_type, preferable_id, created_at, updated_at)
      SELECT user_id, 'Theme', theme_id, created_at, updated_at
      FROM user_theme_preferences
    SQL
  end

  def migrate_area_of_impact_preferences
    return unless table_exists?(:constants) && table_exists?(:constant_maps)

    execute <<~SQL.squish
      INSERT INTO user_preferences (user_id, preferable_type, preferable_id, created_at, updated_at)
      SELECT DISTINCT ON (constant_maps.mappable_id, constant_maps.constant_id)
             constant_maps.mappable_id, 'Constant', constant_maps.constant_id,
             constant_maps.created_at, constant_maps.updated_at
      FROM constant_maps
      INNER JOIN constants ON constants.id = constant_maps.constant_id
      WHERE constant_maps.mappable_type = 'User'
        AND constants.constant_type = #{area_of_impact_constant_type}
      ORDER BY constant_maps.mappable_id, constant_maps.constant_id, constant_maps.id
    SQL

    execute <<~SQL.squish
      DELETE FROM constant_maps
      USING constants
      WHERE constant_maps.mappable_type = 'User'
        AND constant_maps.constant_id = constants.id
        AND constants.constant_type = #{area_of_impact_constant_type}
    SQL
  end

  def restore_theme_preferences
    return unless table_exists?(:user_preferences)

    execute <<~SQL.squish
      INSERT INTO user_theme_preferences (user_id, theme_id, created_at, updated_at)
      SELECT user_id, preferable_id, created_at, updated_at
      FROM user_preferences
      WHERE preferable_type = 'Theme'
    SQL
  end

  def restore_area_of_impact_preferences
    return unless table_exists?(:constants) && table_exists?(:constant_maps)

    execute <<~SQL.squish
      INSERT INTO constant_maps (mappable_type, mappable_id, constant_id, created_at, updated_at)
      SELECT 'User', user_id, preferable_id, created_at, updated_at
      FROM user_preferences
      INNER JOIN constants ON constants.id = user_preferences.preferable_id
      WHERE user_preferences.preferable_type = 'Constant'
        AND constants.constant_type = #{area_of_impact_constant_type}
    SQL
  end
end
