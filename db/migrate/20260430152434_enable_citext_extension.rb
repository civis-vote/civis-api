class EnableCitextExtension < ActiveRecord::Migration[8.1]
  def change
    enable_extension :citext
  end
end
