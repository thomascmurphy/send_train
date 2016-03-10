class CreateUserCoaches < ActiveRecord::Migration
  def change
    create_table :user_coaches do |t|
      t.references :user, index: true, foreign_key: true
      t.references :coach, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
