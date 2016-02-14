class CreateWorkouts < ActiveRecord::Migration
  def change
    create_table :workouts do |t|
      t.string :label
      t.string :workout_type
      t.references :user, index: true, foreign_key: true
      t.text :description
      t.integer :reference_id

      t.timestamps null: false
    end
  end
end
