class Workout < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :microcycles
  has_many :events

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
    mesocycle_events = self.user.events.where(id: mesocycle_event_ids)
    mesocycle_events.each do |event|
      duration = event.end_date - event.start_date
      user_score = self.user.climb_score_for_period(event.end_date + duration - 1.year, event.end_date + duration, type)
      score_difference = self.user.climb_score_difference_for_periods(event.start_date,
                                                                      event.end_date + duration,
                                                                      event.start_date - 2 * duration,
                                                                      event.start_date,
                                                                      type)
      if user_score > 0
        event_scores << (score_difference / user_score)
      else
        if score_difference > 0
          event_scores << 100.0
        else
          event_scores << 0.0
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

end
