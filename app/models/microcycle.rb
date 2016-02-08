class Microcycle < ActiveRecord::Base
  has_and_belongs_to_many :workouts
  has_and_belongs_to_many :mesocycles
  has_many :events

  def panel_class
    case self.microcycle_type
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

  def duration_clean
    duration_hash = {"duration_length": 0, "duration_unit": "days"}
    if self.duration.present?
      mm, ss = self.duration.divmod(60)
      hh, mm = mm.divmod(60)
      dd, hh = hh.divmod(24)
      ww, dd = dd.divmod(7)
      if ww > 0
        duration_hash = {"duration_length": ww, "duration_unit": "weeks"}
      elsif dd > 0
        duration_hash = {"duration_length": dd, "duration_unit": "days"}
      end
    end
    return duration_hash
  end

  def duration_length
    return self.duration_clean[:duration_length]
  end

  def duration_unit
    return self.duration_clean[:duration_unit]
  end

end
