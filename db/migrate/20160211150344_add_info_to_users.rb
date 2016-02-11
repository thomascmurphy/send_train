class AddInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :gym_name, :string
    add_column :users, :climbing_start_date, :datetime
    add_column :users, :grade_format, :string
  end
end
