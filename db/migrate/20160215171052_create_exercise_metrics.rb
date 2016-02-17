class CreateExerciseMetrics < ActiveRecord::Migration
  def change
    create_table :exercise_metrics do |t|
      t.string :label
      t.references :exercise_metric_type, index: true, foreign_key: true
      t.references :exercise, index: true
      t.integer :order

      t.timestamps null: false
    end

    create_table :workout_metrics do |t|
      t.belongs_to :workout_exercise, index: true
      t.belongs_to :exercise_metric, index: true
      t.string :value
    end
  end
end
