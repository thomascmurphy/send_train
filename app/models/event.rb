class Event < ActiveRecord::Base
  belongs_to :user
  belongs_to :workout
  belongs_to :microcycle
  belongs_to :mesocycle
  belongs_to :macrocycle
  belongs_to :parent_event
  has_many :child_events, inverse_of: :parent_event

  def panel_class
    if self.macrocycle.present?
      color_class = " panel-primary"
    else
      case self.event_type
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

    return color_class
  end

  def create_child_events
    if self.macrocycle.present?
      mesocycle_start_date = self.start_date
      mesocycle_count = 1
      microcycle_start_date = self.start_date
      microcycle_count = 1
      self.macrocycle.mesocycles.each do |mesocycle|
        mesocycle_end_date = mesocycle_start_date + mesocycle.duration.seconds
        mesocycle_event = Event.create(label: "#{mesocycle.label} #{mesocycle_count}",
                                       start_date: mesocycle_start_date,
                                       end_date: mesocycle_end_date,
                                       mesocycle_id: mesocycle.id,
                                       parent_event_id: self.id,
                                       user_id: self.user_id,
                                       event_type: mesocycle.mesocycle_type)
        mesocycle.microcycles.each do |microcycle|
          microcycle_end_date = microcycle_start_date + microcycle.duration.seconds
          microcycle_event = Event.create(label: "#{microcycle.label} #{mesocycle_count}",
                                          start_date: microcycle_start_date,
                                          end_date: microcycle_end_date,
                                          microcycle_id: microcycle.id,
                                          parent_event_id: self.id,
                                          user_id: self.user_id,
                                          event_type: microcycle.microcycle_type)
          microcycle_start_date = microcycle_end_date
        end
        mesocycle_start_date = mesocycle_end_date
      end
    end
  end

end
