class MigrateConsultationThemeIdToThemeMaps < ActiveRecord::Migration[8.1]
  def up
    return unless column_exists?(:consultations, :theme_id)

    if table_exists?(:theme_maps)
      execute <<~SQL
        INSERT INTO theme_maps (theme_id, mappable_type, mappable_id, created_at, updated_at)
        SELECT theme_id, 'Consultation', id, NOW(), NOW()
        FROM consultations
        WHERE theme_id IS NOT NULL
        ON CONFLICT DO NOTHING
      SQL
    end

    remove_foreign_key :consultations, column: :theme_id if foreign_key_exists?(:consultations, column: :theme_id)
    remove_column :consultations, :theme_id
  end

  def down
    add_column :consultations, :theme_id, :bigint unless column_exists?(:consultations, :theme_id)
    add_index :consultations, :theme_id unless index_exists?(:consultations, :theme_id)
    add_foreign_key :consultations, :themes, column: :theme_id

    execute <<~SQL
      UPDATE consultations c SET theme_id = (
        SELECT tm.theme_id FROM theme_maps tm
        WHERE tm.mappable_type = 'Consultation' AND tm.mappable_id = c.id
        ORDER BY tm.id
        LIMIT 1
      )
    SQL
  end
end
