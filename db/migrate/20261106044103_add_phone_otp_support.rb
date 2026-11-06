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

  # Normalizes stored numbers to +<country_code><number> (+91 for 10-digit
  # numbers after stripping non-digits and leading zeros — same rules as
  # User.normalize_phone) and clears duplicates, keeping the earliest user so
  # phone login stays unambiguous.
  def normalize_phone_numbers
    execute "UPDATE users SET phone_number = NULL WHERE phone_number = ''"

    execute <<~SQL
      UPDATE users
      SET phone_number = '+' || CASE
        WHEN length(clean.digits) = 10 THEN '91' || clean.digits
        ELSE clean.digits
      END
      FROM (
        SELECT id, regexp_replace(regexp_replace(phone_number, '\\D', '', 'g'), '^0+', '') AS digits
        FROM users
        WHERE phone_number IS NOT NULL AND phone_number <> ''
      ) clean
      WHERE users.id = clean.id AND clean.digits <> ''
    SQL

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
