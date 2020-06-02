# This migration comes from cm_page_builder_rails (originally 20190816103148)
class CreateCmPageBuilderRailsPages < ActiveRecord::Migration[6.0]
  def change
    create_table :cm_page_builder_rails_pages do |t|
      t.references :container, polymorphic: true, null: false, index: { name: 'container_composite_index' }

      t.timestamps
    end
  end
end
