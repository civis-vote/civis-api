class AddConsultationToBlogPosts < ActiveRecord::Migration[8.1]
  def change
    add_reference :blog_posts, :consultation, foreign_key: true
  end
end
