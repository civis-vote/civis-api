# This migration comes from cm_page_builder_rails (originally 20190816105056)

class CreateCmPageBuilderRailsPageComponents < ActiveRecord::Migration[6.0]
  def change
    create_table :cm_page_builder_rails_page_components, id: :string do |t|
      t.references :page, null: false
      t.string :content
      t.integer :position
      t.string :component_type
      t.timestamps
    end
    add_foreign_key :cm_page_builder_rails_page_components, :cm_page_builder_rails_pages, column: :page_id
  end
end
