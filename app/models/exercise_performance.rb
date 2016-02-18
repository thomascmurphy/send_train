class ExercisePerformance < ActiveRecord::Base
  belongs_to :user
  belongs_to :workout_metric
  belongs_to :event
end
