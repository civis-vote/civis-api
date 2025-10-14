class CreateDepartmentContacts < ActiveRecord::Migration[7.1]
  def up
    create_table :department_contacts do |t|
      t.belongs_to :department, null: false, foreign_key: true
      t.string :name
      t.string :email
      t.string :designation
      t.integer :contact_type

      t.timestamps
    end

    # Migrate existing POC emails from departments table
    # contact_type: 0 = primary, 1 = secondary
    execute <<-SQL
      INSERT INTO department_contacts (department_id, email, name, designation, contact_type, created_at, updated_at)
      SELECT
        id as department_id,
        poc_email_primary as email,
        primary_officer_name as name,
        primary_officer_designation as designation,
        0 as contact_type,
        NOW() as created_at,
        NOW() as updated_at
      FROM departments
      WHERE poc_email_primary IS NOT NULL
        AND poc_email_primary != ''
        AND deleted_at IS NULL;
    SQL

    execute <<-SQL
      INSERT INTO department_contacts (department_id, email, name, designation, contact_type, created_at, updated_at)
      SELECT
        id as department_id,
        poc_email_secondary as email,
        secondary_officer_name as name,
        secondary_officer_designation as designation,
        1 as contact_type,
        NOW() as created_at,
        NOW() as updated_at
      FROM departments
      WHERE poc_email_secondary IS NOT NULL
        AND poc_email_secondary != ''
        AND deleted_at IS NULL;
    SQL

    remove_column :departments, :poc_email_primary
    remove_column :departments, :primary_officer_name
    remove_column :departments, :primary_officer_designation
    remove_column :departments, :poc_email_secondary
    remove_column :departments, :secondary_officer_name
    remove_column :departments, :secondary_officer_designation
  end

  def down
    add_column :departments, :poc_email_primary, :string
    add_column :departments, :primary_officer_name, :string
    add_column :departments, :primary_officer_designation, :string
    add_column :departments, :poc_email_secondary, :string
    add_column :departments, :secondary_officer_name, :string
    add_column :departments, :secondary_officer_designation, :string

    drop_table :department_contacts
  end
end
