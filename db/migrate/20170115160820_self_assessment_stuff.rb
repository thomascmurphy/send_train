class SelfAssessmentStuff < ActiveRecord::Migration
  def change
    add_column :workout_exercises, :label, :string
    add_column :exercises, :private, :boolean, :default => false
    add_column :workouts, :private, :boolean, :default => false
    add_column :macrocycles, :private, :boolean, :default => false
    add_column :goals, :private, :boolean, :default => false
  end
end
