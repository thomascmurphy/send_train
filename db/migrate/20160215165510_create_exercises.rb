class CreateExercises < ActiveRecord::Migration
  def change
    create_table :exercises do |t|
      t.string :label
      t.string :exercise_type
      t.text :description
      t.references :user, index: true, foreign_key: true
      t.integer :reference_id

      t.timestamps null: false
    end

    create_table :workout_exercises do |t|
      t.belongs_to :workout, index: true
      t.belongs_to :exercise, index: true
      t.integer :order_in_workout
      t.integer :reps
    end

  end
end
