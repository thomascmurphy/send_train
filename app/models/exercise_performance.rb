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
    case exercise_metric_types.sort
    when ["hold-type", "rest-time", "time", "weight"]
      quantifications = []
      weights = []
      hang_times = []
      hold_type = nil
      sibling_performances.group_by(&:rep).each do |rep, performances|
        rest_time = nil
        hang_time = nil
        weight_original = nil
        weight = nil
        performances.each do |performance|
          case exercise_metric_type_conversion[performance.workout_metric.exercise_metric.exercise_metric_type_id]
          when 'hold-type'
            hold_type = performance.value
          when 'weight'
            weight_original = performance.value.to_i
            weight = performance.user.agnostic_weight(performance.value.to_i) + 20
          when 'time'
            hang_time = performance.value.to_i
          when 'rest-time'
            rest_time = performance.value.to_i
          else
          end
        end
        quantifications << (weight * hang_time)
        weights << weight_original
        hang_times << hang_time
      end
      name = hold_type
      quantification = quantifications.inject{ |sum, el| sum + el }.to_f / quantifications.size
      average_weight = weights.inject{ |sum, el| sum + el }.to_f / weights.size
      average_hang_time = hang_times.inject{ |sum, el| sum + el }.to_f / hang_times.size
      tooltip_value = "#{average_weight.round(2)}#{self.user.default_weight_unit} for #{average_hang_time.round(2)}s"
    when ["repetitions"]
      name = exercise.label
      quantifications = sibling_performances.pluck(:value).map(&:to_i)
      quantification = quantifications.inject{ |sum, el| sum + el }.to_f / quantifications.size
      tooltip_value = "#{quantification.round(2)} reps"
    when ["time"]
      name = exercise.label
      quantifications = sibling_performances.pluck(:value).map(&:to_i)
      quantification = quantifications.inject{ |sum, el| sum + el }.to_f / quantifications.size
      tooltip_value = "#{quantification.round(2)}s"
    when ["boulder-grade"] || ["sport-grade"]
      name = exercise.label
      quantifications = sibling_performances.pluck(:value).map(&:to_i)
      quantification = quantifications.inject{ |sum, el| sum + el }.to_f / quantifications.size
      tooltip_value = Climb.convert_score_to_grades(quantification, self.user.grade_format)
    else
      name = nil
      quantification = nil
    end
    return {'name': name, 'value': quantification, 'tooltip_value': tooltip_value}
  end
end
