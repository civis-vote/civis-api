class CreateCmRole < ActiveRecord::Migration[7.1]
  def change
    create_table :cm_roles do |t|
      t.string :name
      t.string :default_redirect_path, :string, default: "/cm_admin/users"

      t.timestamps
    end
  end
end
