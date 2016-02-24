class WorkoutExercise < ActiveRecord::Base
  belongs_to :workout
  belongs_to :exercise
  has_many :workout_metrics, dependent: :destroy
  has_many :exercise_metrics, through: :workout_metrics

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
end
