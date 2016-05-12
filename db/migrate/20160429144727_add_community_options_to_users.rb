class AddCommunityOptionsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :allow_profile_view, :boolean, default: true
    add_column :users, :allow_followers, :boolean, default: true
    add_column :users, :handle, :string, null: true

    add_index :users, :handle, unique: true
  end
end
