class WorkoutPerformance < ActiveRecord::Base
  belongs_to :user
  belongs_to :workout_exercise_metric
  belongs_to :event
end
