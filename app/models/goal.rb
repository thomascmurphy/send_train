class Goal < ActiveRecord::Base
  belongs_to :user
  belongs_to :parent_goal, class_name: 'Goal', foreign_key: 'parent_goal_id'
  has_many :sub_goals, class_name: 'Goal', foreign_key: 'parent_goal_id', dependent: :destroy

  def panel_class
    if self.completed.present?
      color_class = " panel-success"
    elsif self.sub_goals.present? && self.sub_goals.where(completed: true).present?
      color_class = " panel-warning"
    else
      color_class = " panel-default"
    end

    return color_class
  end

  def percent_complete
    if self.completed.present?
      100.0
    elsif self.sub_goals.present?
      total_completion = 0.0
      self.sub_goals.each do |sub_goal|
        total_completion += sub_goal.percent_complete
      end
      total_completion / (self.sub_goals.count.to_f + 1.0)
    else
      0.0
    end
  end

end
