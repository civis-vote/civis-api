class AddMetaToMinistries < ActiveRecord::Migration[6.0]
  def change
    add_column :ministries, :meta, :jsonb
  end
end
