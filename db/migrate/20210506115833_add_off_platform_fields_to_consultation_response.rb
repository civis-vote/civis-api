class AddOffPlatformFieldsToConsultationResponse < ActiveRecord::Migration[6.0]
  def change
  	add_column :consultation_responses, :import_key, :integer
  	add_column :consultation_responses, :first_name, :string
  	add_column :consultation_responses, :last_name, :string
  	add_column :consultation_responses, :email, :string
  	add_column :consultation_responses, :phone_number, :bigint
  	add_column :consultation_responses, :responded_at, :date
  	add_column :consultation_responses, :source, :integer, default: 0
  end
end
