class ChangeToShowDiscussSection < ActiveRecord::Migration[7.1]
  def change
    rename_column :consultations, :allow_discuss_engage_response, :show_discuss_section
  end
end