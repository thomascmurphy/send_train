class AddRepToExercisePerformances < ActiveRecord::Migration
  def change
    add_column :exercise_performances, :rep, :integer
  end
end
