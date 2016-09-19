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
      pad_count = hold_size_value.to_s.to_r.to_s
    else
      pad_count = hold_size_value.to_s
    end
    pad_string = hold_size_value.to_f > 1 ? "Pads" : "Pad"
    "#{pad_count} #{pad_string}"
  end
end
