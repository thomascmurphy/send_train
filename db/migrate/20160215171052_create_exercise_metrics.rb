class CreateExerciseMetrics < ActiveRecord::Migration
  def change
    create_table :exercise_metrics do |t|
      t.string :label
      t.references :exercise_metric_type, index: true, foreign_key: true
      t.references :exercise, index: true
      t.integer :order

      t.timestamps null: false
    end
  end
end
