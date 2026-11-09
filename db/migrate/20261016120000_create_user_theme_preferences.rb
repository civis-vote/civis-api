class CreateUserThemePreferences < ActiveRecord::Migration[8.1]
  def change
    create_table :user_theme_preferences do |t|
      t.references :user, null: false, foreign_key: true
      t.references :theme, null: false, foreign_key: true
      t.timestamps
    end

    add_index :user_theme_preferences, %i[user_id theme_id], unique: true
  end
end
