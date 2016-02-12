class Event < ActiveRecord::Base
  belongs_to :user
  belongs_to :workout
  belongs_to :microcycle
  belongs_to :mesocycle
  belongs_to :macrocycle
  belongs_to :parent_event, class_name: 'Event', foreign_key: 'parent_event_id'
  #after_create :create_child_events
  before_destroy :destroy_child_events

  def child_events
    return self.user.events.where(parent_event_id: self.id)
  end

  def destroy_child_events
    self.child_events.each do |child_event|
      child_event.destroy
    end
  end

  def set_dates_to_now
    self.start_date = DateTime.now
    self.end_date = DateTime.now
  end

  def smart_label
    if self.label.present?
      self.label
    elsif self.workout.present?
      self.workout.label
    elsif self.macrocycle.present?
      self.macrocycle.label
    else
      self.label
    end
  end

  def smart_event_type
    if self.event_type.present?
      self.label
    elsif self.workout.present?
      self.workout.workout_type
    elsif self.macrocycle.present?
      self.macrocycle.workout_type
    else
      self.label
    end
  end

  def panel_class
    if self.macrocycle.present?
      color_class = " panel-primary"
    else
      case self.smart_event_type
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
    end

    if self.completed.present?
      color_class << " translucent"
    end

    return color_class
  end

  def create_child_events
    if self.macrocycle.present?
      mesocycle_start_date = self.start_date
      microcycle_start_date = self.start_date
      workout_start_date = self.start_date

      mesocycle_count = 1
      self.macrocycle.mesocycles.each do |mesocycle|
        mesocycle_end_date = mesocycle_start_date + mesocycle.duration.seconds
        mesocycle_event = Event.create(label: "#{mesocycle.label} #{mesocycle_count}",
                                       start_date: mesocycle_start_date.beginning_of_day,
                                       end_date: mesocycle_end_date.end_of_day,
                                       mesocycle_id: mesocycle.id,
                                       parent_event_id: self.id,
                                       user_id: self.user_id,
                                       event_type: mesocycle.mesocycle_type)
        microcycle_count = 1
        mesocycle.microcycles.each do |microcycle|
          microcycle_end_date = microcycle_start_date + microcycle.duration.seconds
          microcycle_event = Event.create(label: "#{microcycle.label} #{microcycle_count}",
                                          start_date: microcycle_start_date.beginning_of_day,
                                          end_date: microcycle_end_date.end_of_day,
                                          microcycle_id: microcycle.id,
                                          parent_event_id: mesocycle_event.id,
                                          user_id: self.user_id,
                                          event_type: microcycle.microcycle_type)
          workout_count = 1
          microcycle.workouts.each do |workout|
            workout_end_date = workout_start_date + (microcycle.duration / microcycle.workouts.length)
            workout_event = Event.create(label: "#{workout.label} #{workout_count}",
                                         start_date: workout_start_date.beginning_of_day,
                                         end_date: workout_end_date.end_of_day,
                                         workout_id: workout.id,
                                         parent_event_id: microcycle_event.id,
                                         user_id: self.user_id,
                                         event_type: microcycle.microcycle_type)
            workout_start_date = workout_end_date
            workout_count += 1
          end
          microcycle_start_date = microcycle_end_date
          microcycle_count += 1
        end
        mesocycle_start_date = mesocycle_end_date
        mesocycle_count += 1
      end
    end
  end

  def gym_session_string
    case self.gym_session
    when "boulder"
      gym_session_string = "Bouldering"
    when "sport"
      gym_session_string = "Sport Climbing"
    else
      gym_session_string = ""
    end
  end

  def duration_string(pluralize=false)
    duration_length = ""
    duration_unit = ""
    if self.start_date.present? && self.end_date.present?
      duration = (self.end_date - self.start_date).to_i
      mm, ss = duration.divmod(60)
      hh, mm = mm.divmod(60)
      dd, hh = hh.divmod(24)
      ww, dd = dd.divmod(7)
      if ww > 0
        duration_length = ww
        duration_unit = "Week"
      elsif dd > 0
        duration_length = dd
        duration_unit = "Day"
      elsif hh > 0
        duration_length = hh
        duration_unit = "Hour"
      elsif mm > 0
        duration_length = mm
        duration_unit = "Minute"
      else
        duration_length = 0
        duration_unit = "Hour"
      end
    end
    if pluralize.present?
      return "#{ActionController::Base.helpers.pluralize(duration_length, duration_unit)}"
    else
      return "#{duration_length} #{duration_unit}"
    end
  end

    def self.mondays(starts: nil, ends: nil)
      starts ||= DateTime.now.beginning_of_day - 4.weeks
      ends ||= DateTime.now.beginning_of_day + 1.year
      (starts..ends).select {|d| d.monday? }
    end

    def nice_start_date
      if self.start_date.present?
        self.start_date.strftime("%Y-%m-%d")
      end
    end

    def self.handle_workout_events(weeks, parent_event, user)
      existing_event_ids = parent_event.child_events.pluck(:id)
      updated_ids = []
      weeks.each do |week_count, week|
        week["days"].each do |day_count, day|
          day["workouts"].each do |workout|
            if workout["event_id"].present?
              workout_event = user.events.find_by_id(workout["event_id"].to_i)
              updated_ids << workout["event_id"].to_i
            else
              workout_event = user.events.new
            end
            if workout["id"].present? && parent_event.present?
              workout_event.workout_id = workout["id"]
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
