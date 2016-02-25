class AddDefaultValueToExerciseMetrics < ActiveRecord::Migration
  def change
    add_column :exercise_metrics, :default_value, :string
  end
end
