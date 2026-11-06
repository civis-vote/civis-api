class AddPhoneOtpSupport < ActiveRecord::Migration[8.1]
  def up
    execute "UPDATE users SET email = NULL WHERE email = ''"
    change_column_null :users, :email, true
    change_column_default :users, :email, from: "", to: nil

    add_column :users, :phone_verified_at, :datetime

    normalize_phone_numbers
    add_index :users, :phone_number, unique: true, where: "phone_number IS NOT NULL"

    add_column :otp_requests, :delivery_channel, :integer, default: 0, null: false
  end

  def down
    remove_column :otp_requests, :delivery_channel
    remove_index :users, column: :phone_number
    remove_column :users, :phone_verified_at
    execute "UPDATE users SET email = '' WHERE email IS NULL"
    change_column_default :users, :email, from: nil, to: ""
    change_column_null :users, :email, false
  end

  private

  # Normalizes stored numbers to +<country_code><number> (+91 for 10-digit numbers)
  # and clears duplicates, keeping the earliest user so phone login stays
  # unambiguous.
  def normalize_phone_numbers
    select_all("SELECT id, phone_number FROM users WHERE phone_number IS NOT NULL AND phone_number <> ''").each do |row|
      digits = row['phone_number'].to_s.gsub(/\D/, '')
      next if digits.blank?

      digits = "91#{digits}" if digits.length == 10
      execute "UPDATE users SET phone_number = '+#{digits}' WHERE id = #{row['id']}"
    end

    execute <<~SQL
      UPDATE users SET phone_number = NULL
      WHERE id IN (
        SELECT id FROM (
          SELECT id, ROW_NUMBER() OVER (PARTITION BY phone_number ORDER BY id) AS rn
          FROM users WHERE phone_number IS NOT NULL
        ) dupes WHERE dupes.rn > 1
      )
    SQL
  end
end
