class Exercise < ActiveRecord::Base
  belongs_to :user
  has_many :workout_exercises, dependent: :destroy
  has_many :workouts, through: :workout_exercises
  has_many :exercise_metrics, dependent: :destroy
  has_many :exercise_metric_options, through: :exercise_metrics
  after_create :set_reference_id

  def set_reference_id
    if self.reference_id.blank?
      self[:reference_id] = self.id
      self.save
    end
  end

  def update_workouts
    workout_exercises = WorkoutExercise.where(exercise_id: self.id)
    workout_exercises.each do |workout_exercise|
      existing_workout_metric_ids = workout_exercise.workout_metrics.pluck(:id)
      updated_workout_metric_ids = []
      self.exercise_metrics.each do |exercise_metric|
        if exercise_metric.id.present?
          workout_metric = workout_exercise.workout_metrics.find_or_create_by(exercise_metric_id: exercise_metric.id)
          updated_workout_metric_ids << workout_metric.id
        end
      end
      WorkoutMetric.where(id: existing_workout_metric_ids - updated_workout_metric_ids).destroy_all
    end
  end

  def panel_class
    case self.exercise_type
    when "strength"
      color_class = " panel-danger"
    when "power"
      color_class = " panel-orange"
    when "powerendurance"
      color_class = " panel-warning"
    when "endurance"
      color_class = " panel-success"
    when "technique"
      color_class = " panel-info"
    when "cardio"
      color_class = " panel-default"
    else
      color_class = " panel-default"
    end

    return color_class
  end

  def alert_class
    case self.exercise_type
    when "strength"
      color_class = " alert-danger"
    when "power"
      color_class = " alert-orange"
    when "powerendurance"
      color_class = " alert-warning"
    when "endurance"
      color_class = " alert-success"
    when "technique"
      color_class = " alert-info"
    when "cardio"
      color_class = " alert-info"
    else
      color_class = " alert-info"
    end

    return color_class
  end

  def handle_exercise_metrics(exercise_metrics_params)
    existing_exercise_metric_ids = self.exercise_metrics.pluck(:id)
    updated_exercise_metric_ids = []
    existing_exercise_metric_option_ids = self.exercise_metric_options.pluck(:id)
    updated_exercise_metric_option_ids = []
    if exercise_metrics_params.present?
      exercise_metrics_params.each_with_index do |exercise_metric_params, metric_index|
        exercise_metric_id = exercise_metric_params.with_indifferent_access["id"].to_i
        if exercise_metric_id.present? && exercise_metric_id != 0
          exercise_metric = self.exercise_metrics.find_by_id(exercise_metric_id)
          if exercise_metric.blank?
            next
          end
          updated_exercise_metric_ids << exercise_metric_id
        else
          exercise_metric = self.exercise_metrics.new
        end
        exercise_metric_label = exercise_metric_params.with_indifferent_access["label"]
        if exercise_metric_label.present?
          exercise_metric.label = exercise_metric_label
          exercise_metric.exercise_metric_type_id = exercise_metric_params.with_indifferent_access["exercise_metric_type_id"].to_i
          exercise_metric.order_in_exercise = metric_index
          exercise_metric.default_value = exercise_metric_params.with_indifferent_access["default_value"]
          exercise_metric.save
        else
          next
        end
        exercise_metric_options = exercise_metric_params.with_indifferent_access["exercise_metric_options"]
        if exercise_metric_options.present?
          exercise_metric_options.each_with_index do |exercise_metric_option_params, option_index|
            exercise_metric_option_id = exercise_metric_option_params.with_indifferent_access["id"].to_i
            if exercise_metric_option_id.present? && exercise_metric_option_id != 0
              exercise_metric_option = exercise_metric.exercise_metric_options.find_by_id(exercise_metric_option_id)
              if exercise_metric_option.blank?
                next
              end
              updated_exercise_metric_option_ids << exercise_metric_option_id
            else
              exercise_metric_option = exercise_metric.exercise_metric_options.new
            end
            exercise_metric_option_label = exercise_metric_option_params.with_indifferent_access["label"]
            if exercise_metric_option_label.present?
              old_metric_option_value = exercise_metric_option.value
              exercise_metric_option.label = exercise_metric_option_params.with_indifferent_access["label"]
              #exercise_metric_option.value = exercise_metric_option_params.with_indifferent_access["label"].parameterize
              exercise_metric_option.value = exercise_metric_option_params.with_indifferent_access["label"]
              exercise_metric_option.order_in_metric = option_index
              exercise_metric_option.save
              exercise_metric_option.update_values(old_metric_option_value)
            end
          end
        end
      end
    end
    if (existing_exercise_metric_ids - updated_exercise_metric_ids).present?
      ExerciseMetric.where(id: existing_exercise_metric_ids - updated_exercise_metric_ids).destroy_all
    end
    if (existing_exercise_metric_option_ids - updated_exercise_metric_option_ids).present?
      ExerciseMetricOption.where(id: existing_exercise_metric_option_ids - updated_exercise_metric_option_ids).destroy_all
    end
    self.update_workouts()
  end

  def duplicate(user, old_workout_id=nil, new_workout_id=nil)
    exercise_metric_id_conversion = {}
    new_exercise = self.dup
    new_exercise.user_id = user.id
    if new_workout_id.blank?
      if self.user_id == user.id
        new_exercise.label += " (copy)"
      else
        new_exercise.label += " (from #{self.user.smart_name})"
      end
    end
    if new_exercise.save
      self.exercise_metrics.each do |exercise_metric|
        new_exercise_metric = exercise_metric.duplicate(user, new_exercise.id)
        exercise_metric_id_conversion[exercise_metric.id] = new_exercise_metric.id
      end
      if old_workout_id.present? && new_workout_id.present?
        self.workout_exercises.where(workout_id: old_workout_id).each do |workout_exercise|
          workout_exercise.duplicate(user, new_exercise.id, new_workout_id, exercise_metric_id_conversion)
        end
      end
      return new_exercise
    end
  end


end
