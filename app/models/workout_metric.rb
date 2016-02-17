class WorkoutMetric < ActiveRecord::Base
  belongs_to :workout_exercise
  belongs_to :exercise_metric
end
