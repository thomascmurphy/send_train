class RemoveDefaultDateTimes < ActiveRecord::Migration
  def change
    change_column :attempts, :date, :datetime, :default => nil
    change_column :events, :start_date, :datetime, :default => nil
    change_column :events, :end_date, :datetime, :default => nil
  end
end
