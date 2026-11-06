class CreateBlogPosts < ActiveRecord::Migration[8.1]
  def change
    create_table :blog_posts do |t|
      t.string :title, null: false
      t.citext :slug, index: { unique: true }
      t.text :description
      t.integer :status, default: 0, null: false
      t.datetime :published_at
      t.datetime :archived_at
      t.references :blog_category, foreign_key: true
      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
