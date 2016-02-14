class Macrocycle < ActiveRecord::Base
  belongs_to :user
  has_many :macrocycle_workouts
  has_many :workouts, through: :macrocycle_workouts
  has_many :events, dependent: :destroy

  def panel_class
    return " panel-primary"
  end

  def duration_days
    return self.macrocycle_workouts.pluck(:day_in_cycle).max
  end

  def duration_weeks
    days = self.duration_days
    if days.present?
      weeks, dd = days.divmod(7)
    else
      weeks = 0
    end
    weeks = weeks + 1
    return weeks
  end

  def label_with_duration
    return "#{self.label} (#{self.duration_weeks} Weeks)"
  end

  def workouts_by_day
    workouts_by_day = {}
    self.macrocycle_workouts.each do |macrocycle_workout|
      if workouts_by_day[macrocycle_workout.day_in_cycle].present?
        workouts_by_day[macrocycle_workout.day_in_cycle] << macrocycle_workout
      else
        workouts_by_day[macrocycle_workout.day_in_cycle] = [macrocycle_workout]
      end
    end
    return workouts_by_day
  end

  def handle_workouts_and_events(weeks, parent_event)
      existing_macrocycle_workout_ids = self.macrocycle_workouts.pluck(:id)
      updated_macrocycle_workout_ids = []
      existing_event_ids = parent_event.present? ? parent_event.child_events.pluck(:id) : nil
      updated_event_ids = []
      if weeks.present?
        weeks.each do |week_count, week|
          week["days"].each do |day_count, day|
            day["workouts"].each do |workout|

              if workout["macrocycle_workout_id"].present?
                macrocycle_workout = self.macrocycle_workouts.find_by_id(workout["macrocycle_workout_id"].to_i)
                updated_macrocycle_workout_ids << workout["macrocycle_workout_id"].to_i
              else
                macrocycle_workout = self.macrocycle_workouts.new
              end
              if workout["id"].present?
                macrocycle_workout.day_in_cycle = day_count.to_i + (week_count.to_i - 1)*7
                macrocycle_workout.workout_id = workout["id"].to_i
                macrocycle_workout.save
              end

              if parent_event.present?
                if workout["event_id"].present?
                  workout_event = user.events.find_by_id(workout["event_id"].to_i)
                  updated_event_ids << workout["event_id"].to_i
                else
                  workout_event = user.events.new
                end
                if workout["id"].present?
                  workout_event.workout_id = workout["id"].to_i
                  start_date = parent_event.start_date + (week_count.to_i - 1).weeks + (day_count.to_i - 1).days
                  workout_event.start_date = start_date.beginning_of_day
                  workout_event.end_date = start_date.end_of_day
                  workout_event.parent_event_id = parent_event.id
                  workout_event.save
                end
              end

            end
          end
        end
      end

      if existing_macrocycle_workout_ids.present?
        MacrocycleWorkout.where(id: existing_macrocycle_workout_ids - updated_macrocycle_workout_ids).destroy_all
      end
      if existing_event_ids.present?
        Event.where(id: existing_event_ids - updated_event_ids).destroy_all
      end
    end

  def efficacy(type)
    event_scores = []
    self.events.each do |event|
      event_scores << self.user.climb_score_difference_for_periods(event.start_date,
                                                                   event.end_date + self.duration.seconds,
                                                                   event.start_date - (2 * self.duration).seconds,
                                                                   event.start_date,
                                                                   type)
    end
    return (event_scores.inject{ |sum, el| sum + el }.to_f / event_scores.size) * 100
  end

end
