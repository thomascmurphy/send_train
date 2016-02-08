class Mesocycle < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :microcycles
  has_and_belongs_to_many :macrocycles
  has_many :events

  def panel_class
    case self.mesocycle_type
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

  def duration
    duration = 0
    self.microcycles.each do |microcycle|
      duration += microcycle.duration
    end
    return duration
  end

end
