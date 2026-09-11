class CreateShowcaseSlides < ActiveRecord::Migration[8.1]
  def change
    create_table :showcase_slides do |t|
      t.string :title, null: false
      t.string :cta_url, null: false
      t.string :video_url
      t.string :cta_label, null: false
      t.integer :status, default: 0, null: false
      t.integer :position
      t.datetime :published_at
      t.datetime :archived_at
      t.references :created_by, foreign_key: { to_table: :users }, index: true
      t.references :updated_by, foreign_key: { to_table: :users }, index: true

      t.timestamps
    end
  end
end
