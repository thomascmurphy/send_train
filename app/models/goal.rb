class Goal < ActiveRecord::Base
  belongs_to :user
  belongs_to :parent_goal
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

end
