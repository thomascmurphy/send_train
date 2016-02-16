class WorkoutPerformance < ActiveRecord::Base
  belongs_to :user
  belongs_to :exercise_metric
  belongs_to :event
end
