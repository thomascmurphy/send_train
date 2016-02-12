class Macrocycle < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :mesocycles
  has_many :microcycles, through: :mesocycles
  has_many :workouts, through: :microcycles
  has_many :events

  def panel_class
    return " panel-primary"
  end

  def duration
    duration = 0
    self.mesocycles.each do |mesocycle|
      duration += mesocycle.duration
    end
    return duration
  end

  def duration_string
    duration_length = ""
    duration_unit = ""
    if self.duration.present?
      mm, ss = self.duration.divmod(60)
      hh, mm = mm.divmod(60)
      dd, hh = hh.divmod(24)
      ww, dd = dd.divmod(7)
      if ww > 0
        duration_length = ww
        duration_unit = "Week"
      elsif dd > 0
        duration_length = dd
        duration_unit = "Day"
      end
    end
    return "#{ActionController::Base.helpers.pluralize(duration_length, duration_unit)}"
  end

  def label_with_duration
    return "#{self.label} (#{self.duration_string})"
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
