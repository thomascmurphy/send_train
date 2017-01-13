class AddMountainProject < ActiveRecord::Migration
  def change
    add_column :users, :mountain_project_user_id, :integer

    add_column :climbs, :mountain_project_id, :integer
    add_column :climbs, :mountain_project_url, :text

    add_index :climbs, :mountain_project_id
  end
end
