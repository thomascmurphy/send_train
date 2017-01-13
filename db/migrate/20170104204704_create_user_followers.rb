class CreateUserFollowers < ActiveRecord::Migration
  def change
    create_table :user_followers do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :follower_id

      t.timestamps null: false
    end
  end
end
