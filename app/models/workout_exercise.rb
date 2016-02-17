class WorkoutExercise < ActiveRecord::Base
  belongs_to :workout
  belongs_to :exercise
  has_many :workout_metrics, dependent: :destroy
  has_many :exercise_metrics, through: :workout_metrics
end
