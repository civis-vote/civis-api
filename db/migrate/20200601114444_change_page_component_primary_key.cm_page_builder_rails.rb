# This migration comes from cm_page_builder_rails (originally 20190903110322)
class ChangePageComponentPrimaryKey < ActiveRecord::Migration[6.0]
  def change
    rename_column :cm_page_builder_rails_page_components, :id, :uuid
    CmPageBuilder::Rails::PageComponent.connection.execute(
      <<~SQL
      ALTER TABLE cm_page_builder_rails_page_components DROP CONSTRAINT cm_page_builder_rails_page_components_pkey;
      SQL
    )
    add_column :cm_page_builder_rails_page_components, :id, :primary_key
  end
end
