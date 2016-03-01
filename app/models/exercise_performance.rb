class ExercisePerformance < ActiveRecord::Base
  belongs_to :user
  belongs_to :workout_metric
  belongs_to :event

  def quantify
    exercise_metric_type_conversion = {}
    ExerciseMetricType.all.each do |exercise_metric_type|
      exercise_metric_type_conversion[exercise_metric_type.id] = exercise_metric_type.slug
    end
    exercise = self.workout_metric.exercise_metric.exercise
    workout_exercise = self.workout_metric.workout_exercise
    workout_metric_ids = WorkoutMetric.where(workout_exercise_id: workout_exercise.id).pluck(:id)
    sibling_performances = ExercisePerformance.where(event_id: self.event_id, workout_metric_id: workout_metric_ids)
    exercise_metric_types = exercise.exercise_metrics.pluck(:exercise_metric_type_id).map{|type_id| exercise_metric_type_conversion[type_id]}
  end
end
