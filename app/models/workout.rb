class Workout < ActiveRecord::Base
  belongs_to :user
  has_many :macrocycle_workouts, dependent: :destroy
  has_many :macrocycles, through: :macrocycle_workouts
  has_many :events, dependent: :destroy
  has_many :workout_exercises, dependent: :destroy
  has_many :exercises, through: :workout_exercises
  has_many :workout_metrics, through: :workout_exercises
  after_create :set_reference_id

  def set_reference_id
    if self.reference_id.blank?
      self[:reference_id] = self.id
      self.save
    end
  end

  def workout_exercises_ordered
    self.workout_exercises.order(:order_in_workout)
  end

  def panel_class
    case self.workout_type
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
    case self.workout_type
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

  def efficacy(type="all")
    event_scores = []
    completed_events = self.events.where(completed: true)
    mesocycle_event_ids = []
    completed_events.each do |event|
      microcycle_event = event.parent_event
      if microcycle_event.present?
        mesocycle_event_ids << microcycle_event.parent_event_id
      end
    end
    mesocycle_events = self.user.events.where(id: mesocycle_event_ids.uniq)
    mesocycle_events.each do |event|
      duration = event.end_date - event.start_date
      end_date = event.end_date + 2 * duration
      if end_date < DateTime.now
        user_score = self.user.climb_score_for_period(event.end_date - 1.year, event.end_date, type)
        score_difference = self.user.climb_score_difference_for_periods(event.start_date,
                                                                        end_date,
                                                                        event.start_date - 3 * duration,
                                                                        event.start_date,
                                                                        type)
        if user_score != 0
          event_scores << (score_difference / user_score)
        else
          if score_difference != 0
            event_scores << 1.0
          else
            event_scores << 0.0
          end
        end
      end
    end
    if event_scores.size > 0
      efficacy = ((event_scores.inject{ |sum, el| sum + el }.to_f / event_scores.size) * 100).round
    else
      efficacy = 0
    end
    return efficacy
  end

  def efficacy_nice(type="all")
    efficacy = self.efficacy(type)
    efficacy_nice = "Unproven"
    if efficacy != 0
      efficacy_nice = efficacy
    end
    return efficacy_nice
  end

  def handle_workout_exercises(workout_exercises_params)
    existing_workout_exercise_ids = self.workout_exercises.pluck(:id)
    updated_workout_exercise_ids = []
    existing_workout_metric_ids = self.workout_metrics.pluck(:id)
    updated_workout_metric_ids = []
    if workout_exercises_params.present?
      workout_exercises_params.each_with_index do |workout_exercise_params, exercise_index|
        workout_exercise_id = workout_exercise_params.with_indifferent_access["id"].to_i
        if workout_exercise_id.present? && workout_exercise_id != 0
          workout_exercise = self.workout_exercises.find_by_id(workout_exercise_id)
          if workout_exercise.blank?
            next
          end
          updated_workout_exercise_ids << workout_exercise_id
        else
          exercise_id = workout_exercise_params.with_indifferent_access["exercise_id"].to_i
          if exercise_id.present? && exercise_id != 0
            workout_exercise = self.workout_exercises.new
            workout_exercise.exercise_id = exercise_id
          else
            next
          end
        end
        workout_exercise.reps = workout_exercise_params.with_indifferent_access["reps"].to_i
        workout_exercise.order_in_workout = exercise_index
        workout_exercise.save

        workout_metrics = workout_exercise_params.with_indifferent_access["workout_metrics"]
        if workout_metrics.present?
          workout_metrics.each_with_index do |workout_metric_params, metric_index|
            workout_metric_id = workout_metric_params.with_indifferent_access["id"].to_i
            if workout_metric_id.present? && workout_metric_id != 0
              workout_metric = workout_exercise.workout_metrics.find_by_id(workout_metric_id)
              if workout_metric.blank?
                next
              end
              updated_workout_metric_ids << workout_metric_id
            else
              exercise_metric_id = workout_metric_params.with_indifferent_access["exercise_metric_id"].to_i
              if exercise_metric_id.present? && exercise_metric_id != 0
                workout_metric = workout_exercise.workout_metrics.new
                workout_metric.exercise_metric_id = exercise_metric_id
              else
                next
              end
            end
            workout_metric.value = workout_metric_params.with_indifferent_access["value"]
            workout_metric.save
          end
        end
      end
    end
    if (existing_workout_exercise_ids - updated_workout_exercise_ids).present?
      WorkoutExercise.where(id: existing_workout_exercise_ids - updated_workout_exercise_ids).destroy_all
    end
    if (existing_workout_metric_ids - updated_workout_metric_ids).present?
      WorkoutMetric.where(id: existing_workout_metric_ids - updated_workout_metric_ids).destroy_all
    end
  end

end
