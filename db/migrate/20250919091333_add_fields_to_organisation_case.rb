class AddFieldsToOrganisationCase < ActiveRecord::Migration[7.1]
  def change
    add_column :organisations, :engagement_type, :integer
    add_column :case_studies, :case_study_type, :integer
    add_reference :case_studies, :theme, foreign_key: true
  end
end
