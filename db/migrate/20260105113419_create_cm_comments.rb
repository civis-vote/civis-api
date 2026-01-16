class CreateCmComments < ActiveRecord::Migration[8.1]
  def change
    create_table :cm_comments do |t|
      t.references :commenter, polymorphic: true
      t.references :commentable, polymorphic: true
      t.timestamps
    end
  end
end
