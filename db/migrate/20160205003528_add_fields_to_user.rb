class AddFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :birthdate, :date
    add_column :users, :gender, :string
    add_column :users, :weight, :integer
    add_column :users, :weight_unit, :string
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :postcode, :string
    add_column :users, :is_admin, :boolean
    add_column :users, :default_weight_unit, :string, default: "lb"
    add_column :users, :default_length_unit, :string, default: "ft"
    add_column :users, :gym_name, :string
    add_column :users, :climbing_start_date, :datetime
    add_column :users, :grade_format, :string
  end
end
