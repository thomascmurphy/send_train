class CreateExerciseMetricOptions < ActiveRecord::Migration
  def change
    create_table :exercise_metric_options do |t|
      t.string :label
      t.string :value
      t.references :exercise_metric, index: true, foreign_key: true
      t.integer :order

      t.timestamps null: false
    end
  end
end
