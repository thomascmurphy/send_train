class CreateExerciseMetricTypes < ActiveRecord::Migration
  def change
    create_table :exercise_metric_types do |t|
      t.string :label
      t.string :input_field
      t.string :slug

      t.timestamps null: false
    end
  end
end
