class CreateExercisePerformances < ActiveRecord::Migration
  def change
    create_table :exercise_performances do |t|
      t.references :user, index: true, foreign_key: true
      t.references :exercise_metric, index: true, foreign_key: true
      t.string :value
      t.references :event, index: true, foreign_key: true
      t.datetime :date

      t.timestamps null: false
    end
  end
end
