class Event < ActiveRecord::Base
  belongs_to :user
  belongs_to :workout
  belongs_to :microcycle
  belongs_to :mesocycle
  belongs_to :macrocycle
  belongs_to :parent_event, class_name: 'Event', foreign_key: 'parent_event_id'
  after_create :create_child_events
  before_destroy :destroy_child_events
  after_save :check_child_completion

  def child_events
    return self.user.events.where(parent_event_id: self.id)
  end

  def completed_child_events
    return self.user.events.where(parent_event_id: self.id, completed: true)
  end

  def percent_complete
    if self.child_events.present?
      return (self.completed_child_events.count.to_f/self.child_events.count.to_f) * 100
    else
      if self.complete?
        return 100
      else
        return 0
      end
    end
  end

  def destroy_child_events
    self.child_events.each do |child_event|
      child_event.destroy
    end
  end

  def check_child_completion
    if self.parent_event.present?
      if self.parent_event.percent_complete == 100 && self.parent_event.completed.blank?
        self.parent_event.completed = true
        self.parent_event.save
      elsif self.parent_event.percent_complete < 100 && self.parent_event.completed.present?
        self.parent_event.completed = false
        self.parent_event.save
      end
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

  def alert_class
    alert_class = ""
    if self.completed.present?
      alert_class = "translucent"
    end
    return alert_class
  end

  def create_child_events
    if self.macrocycle.present?
      self.macrocycle.macrocycle_workouts.each do |macrocycle_workout|
        event_date = self.start_date + (macrocycle_workout.day_in_cycle - 1).days
        event = self.user.events.create(start_date: event_date.beginning_of_day,
                                        end_date: event_date.end_of_day,
                                        workout_id: macrocycle_workout.workout.id,
                                        parent_event_id: self.id)
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


end
