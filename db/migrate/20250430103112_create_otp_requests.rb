class CreateOtpRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :otp_requests do |t|
      t.string :otp
      t.datetime :expired_at
      t.integer :status
      t.datetime :verified_at
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
