class CreateCmUserMentions < ActiveRecord::Migration[8.1]
  def change
    create_table :cm_user_mentions do |t|
      t.references :mentioned, polymorphic: true
      t.references :mentionable, polymorphic: true

      t.timestamps
    end
  end
end
