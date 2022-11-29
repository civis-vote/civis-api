class AddSubjectiveAndObjectiveResponseCount < ActiveRecord::Migration[6.0]
  def change
    add_column :consultation_responses, :subjective_answer_count, :integer
    add_column :consultation_responses, :objective_answer_count, :integer
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
