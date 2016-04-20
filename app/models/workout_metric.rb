class WorkoutMetric < ActiveRecord::Base
  belongs_to :workout_exercise
  belongs_to :exercise_metric
  has_many :exercise_performances, dependent: :destroy
end
