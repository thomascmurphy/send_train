class ExerciseMetric < ActiveRecord::Base
  belongs_to :exercise_metric_type
  belongs_to :exercise
  has_many :exercise_metric_options, dependent: :destroy
  has_many :workout_metrics, dependent: :destroy
  after_save :cleanup_options

  def cleanup_options
    if self.exercise_metric_type.present?
      unless self.exercise_metric_type.label == "Hold Type"
        if self.exercise_metric_options.present?
          self.exercise_metric_options.destroy_all
        end
      end
    end
  end

  def duplicate(user, exercise_id=nil)
    new_exercise_metric = self.dup
    if exercise_id.present?
      new_exercise_metric.exercise_id = exercise_id
    end
    if new_exercise_metric.save
      self.exercise_metric_options.each do |exercise_metric_option|
        exercise_metric_option.duplicate(user, new_exercise_metric.id)
      end
      return new_exercise_metric
    end
  end

  def unit_string(parentheses=false)
    case self.exercise_metric_type.slug
    when "weight"
      units = "#{self.exercise.user.default_weight_unit}s"
    when "time"
      units = "seconds"
    when "hold-size"
      units = "pads"
    when "completion"
      units = "%"
    else
      units = ""
    end
    if parentheses.present? && units.present?
      return "(#{units})"
    else
      return units
    end
  end

end
