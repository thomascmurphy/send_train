class WorkoutExercise < ActiveRecord::Base
  belongs_to :workout
  belongs_to :exercise
  has_many :workout_metrics, dependent: :destroy
  has_many :exercise_metrics, through: :workout_metrics
  after_create :set_label

  def set_label
    if self.exercise.present? && self.label.blank?
      self.label = self.exercise.label
      self.save
    end
  end

  def duplicate(user, new_exercise_id, new_workout_id, exercise_metric_id_conversion=nil)
    new_workout_exercise = self.dup
    new_workout_exercise.exercise_id = new_exercise_id
    new_workout_exercise.workout_id = new_workout_id
    if new_workout_exercise.save
      self.workout_metrics.each do |workout_metric|
        new_workout_metric = workout_metric.dup
        new_workout_metric.workout_exercise_id = new_workout_exercise.id
        if exercise_metric_id_conversion.present?
          new_workout_metric.exercise_metric_id = exercise_metric_id_conversion[workout_metric.exercise_metric_id]
        end
        new_workout_metric.save
      end
      return new_workout_exercise
    end
  end

  def useful_label
    useful_label = self.exercise.label
    workout_metrics = self.workout_metrics.all
    workout_metrics.each do |workout_metric|
      if workout_metric.exercise_metric.exercise_metric_type_id == ExerciseMetricType::HOLD_TYPE_ID
        useful_label = workout_metric.value.capitalize
      end
    end
    return useful_label
  end

  def is_rest
    is_rest = false
    workout_metrics = self.workout_metrics.all
    if workout_metrics.count == 1 && workout_metrics.first.exercise_metric.exercise_metric_type_id == ExerciseMetricType::REST_TIME_ID
      is_rest = true
    end
    is_rest
  end



end
