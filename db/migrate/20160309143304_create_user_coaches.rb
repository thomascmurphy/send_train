class CreateUserCoaches < ActiveRecord::Migration
  def change
    create_table :user_coaches do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :coach_id, index: true
      t.timestamps null: false
    end
  end
end
