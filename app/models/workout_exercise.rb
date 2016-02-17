class WorkoutExercise < ActiveRecord::Base
  belongs_to :workout
  belongs_to :exercise
  has_many :workout_exercise_exercise_metrics
  has_many :exercise_metrics, through: :workout_exercise_exercise_metrics
end
