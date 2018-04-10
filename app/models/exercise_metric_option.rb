class ExerciseMetricOption < ActiveRecord::Base
  belongs_to :exercise_metric

  def duplicate(user, exercise_metric_id=nil)
    new_exercise_metric_option = self.dup
    if exercise_metric_id.present?
      new_exercise_metric_option.exercise_metric_id = exercise_metric_id
    end
    new_exercise_metric_option.save
    return new_exercise_metric_option
  end

  def self.pretty_hold_size(hold_size_value)
    if hold_size_value.to_i != hold_size_value.to_f
      if hold_size_value.to_f > 1
        pad_count_int = hold_size_value.to_i
        pad_count_fraction = (hold_size_value.to_f - pad_count_int).to_r
        pad_count = "#{pad_count_int} #{pad_count_fraction}"
      else
        pad_count = hold_size_value.to_s.to_r.to_s
      end
    else
      pad_count = hold_size_value.to_s
    end
    if hold_size_value > 4
      pad_string = "mm"
    else
      pad_string = hold_size_value.to_f > 1 ? "Pads" : "Pad"
    end

    "#{pad_count} #{pad_string}"
  end

  def update_values(old_value)
    if old_value != self.value
      workout_metrics = self.exercise_metric.workout_metrics
      workout_metrics.where(value: old_value).each do |workout_metric|
        workout_metric.value = self.value
        workout_metric.save
        exercise_performances = workout_metric.exercise_performances
        exercise_performances.where(value: old_value).each do |exercise_performance|
          exercise_performance.value = self.value
          exercise_performance.save
        end
      end
    end
  end

end
