class AddIsCatalystAIEnabledToCmRoles < ActiveRecord::Migration[8.1]
  def change
    add_column :cm_roles, :is_catalyst_ai_enabled, :boolean, default: false, null: false
  end
end
