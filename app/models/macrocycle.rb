class Macrocycle < ActiveRecord::Base
  belongs_to :user
  has_many :macrocycle_workouts, dependent: :destroy
  has_many :workouts, through: :macrocycle_workouts
  has_many :events, dependent: :destroy
  has_many :votes, as: :voteable, dependent: :destroy
  has_many :messages, as: :messageable, dependent: :destroy
  after_create :set_reference_id, :auto_upvote

  SEEDED_REFERENCE_IDS = [1, 2, 3]

  def set_reference_id
    if self.reference_id.blank?
      self[:reference_id] = self.id
      self.save
    end
  end

  def auto_upvote
    Vote.item_auto_upvote(self)
  end

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
    self.macrocycle_workouts.order(:day_in_cycle, :order_in_day).each do |macrocycle_workout|
      if workouts_by_day[macrocycle_workout.day_in_cycle].present?
        workouts_by_day[macrocycle_workout.day_in_cycle] << macrocycle_workout
      else
        workouts_by_day[macrocycle_workout.day_in_cycle] = [macrocycle_workout]
      end
    end
    return workouts_by_day
  end

  def handle_workouts(weeks)
      existing_macrocycle_workout_ids = self.macrocycle_workouts.pluck(:id)
      updated_macrocycle_workout_ids = []
      if weeks.present?
        weeks.each do |week_count, week|
          week.with_indifferent_access["days"].each do |day_count, day|
            workout_ids = day.with_indifferent_access["workout_ids"].split(' ')
            macrocycle_workout_ids = day.with_indifferent_access["macrocycle_workout_ids"].split(' ')
            workout_ids.each_with_index do |workout_id, index|
              macrocycle_workout_id = macrocycle_workout_ids[index].to_i
              if macrocycle_workout_id.present? && macrocycle_workout_id != 0
                macrocycle_workout = self.macrocycle_workouts.find_by_id(macrocycle_workout_id)
                if macrocycle_workout.blank?
                  next
                end
                updated_macrocycle_workout_ids << macrocycle_workout_id
              else
                macrocycle_workout = self.macrocycle_workouts.new
              end
              macrocycle_workout.order_in_day = index
              macrocycle_workout.day_in_cycle = day_count.to_i + (week_count.to_i - 1)*7
              macrocycle_workout.workout_id = workout_id.to_i
              macrocycle_workout.save
            end
          end
        end
      end

      if (existing_macrocycle_workout_ids - updated_macrocycle_workout_ids).present?
        MacrocycleWorkout.where(id: existing_macrocycle_workout_ids - updated_macrocycle_workout_ids).destroy_all
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

  def duplicate(user)
    new_macrocycle = self.dup
    new_macrocycle.user_id = user.id
    if self.user_id == user.id
      new_macrocycle.label += " (copy)"
    else
      new_macrocycle.label += " (from #{self.user.smart_name})"
    end
    referenced_workouts = user.workouts.pluck(:reference_id)
    if new_macrocycle.save
      if self.user_id != user.id
        self.workouts.uniq.each do |workout|
          if referenced_workouts.include? workout.reference_id
            self.macrocycle_workouts.where(workout_id: workout.id).each do |macrocycle_workout|
              macrocycle_workout.duplicate(user, macrocycle_workout.workout_id, new_macrocycle.id)
            end
          else
            workout.duplicate(user, self.id, new_macrocycle.id)
          end
        end
      else
        self.macrocycle_workouts.each do |macrocycle_workout|
          macrocycle_workout.duplicate(user, macrocycle_workout.workout_id, new_macrocycle.id)
        end
      end
      return new_macrocycle
    end
  end

end
