class CreateConsultationResponseVotes < ActiveRecord::Migration[6.0]
  def change
    create_table :consultation_response_votes do |t|
      t.references :consultation_response, null: false, foreign_key: true
      t.integer :vote_direction
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
