class CreateBlogPosts < ActiveRecord::Migration[8.1]
  def change
    create_table :blog_posts do |t|
      t.string :title, null: false
      t.string :slug
      t.text :description
      t.integer :status, default: 0, null: false
      t.datetime :published_at
      t.datetime :archived_at
      t.references :blog_category, foreign_key: true
      t.references :created_by, foreign_key: { to_table: :users }, index: true
      t.references :updated_by, foreign_key: { to_table: :users }, index: true

      t.timestamps
    end

    add_index :blog_posts, :slug
  end
end
