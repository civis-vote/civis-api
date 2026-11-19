class CreateJoinTableCmRoleCtUserGroup < ActiveRecord::Migration[8.1]
  def change
    create_join_table :cm_roles, :ct_user_groups do |t|
      t.index [:cm_role_id, :ct_user_group_id], unique: true
      t.index [:ct_user_group_id, :cm_role_id]
    end
  end
end
