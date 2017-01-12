class AddDefaultGradeFormatToUsers < ActiveRecord::Migration
  def up
    change_column :users, :grade_format, :string, :default => "western"
  end

  def down
    change_column :users, :grade_format, :string, :default => nil
  end
end
