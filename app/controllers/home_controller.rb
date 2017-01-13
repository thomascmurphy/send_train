class HomeController < ApplicationController
  def index
    if user_signed_in?
      @activities = current_user.dashboard_activity
      @goals = Goal.where(user_id: current_user.id, parent_goal_id: nil, completed: false)
      render :dashboard
    end
  end

  def privacy_policy
  end

  def terms_of_service
  end
end
