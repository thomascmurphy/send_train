class WorkoutMetric < ActiveRecord::Base
  belongs_to :workout_exercise
  belongs_to :exercise_metric
  has_many :exercise_performances, dependent: :destroy
  scope :ordered_by_metric, -> { joins(:exercise_metric).order("exercise_metrics.order_in_exercise") }
end
