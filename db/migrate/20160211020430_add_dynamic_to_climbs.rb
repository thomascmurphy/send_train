class AddDynamicToClimbs < ActiveRecord::Migration
  def change
    add_column :climbs, :dynamic, :boolean, default: false
  end
end
