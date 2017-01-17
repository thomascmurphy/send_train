class AddCalculatedValueToExercisePerformances < ActiveRecord::Migration
  def change
    add_column :exercise_performances, :calculated_value, :float
  end
end
