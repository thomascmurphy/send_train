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
end
