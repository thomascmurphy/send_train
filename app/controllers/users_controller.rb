class UsersController < ApplicationController
  before_filter :require_admin!, :except => [:onboarding, :onboarding_skip]

  def require_admin!
    unless true_user.is_admin?
      redirect_to root_path, notice: 'You aint qualified fool!'
    end
  end

  def index
    @users = User.all.order(current_sign_in_at: :desc)
  end

  def impersonate
    user = User.find(params[:user_id])
    impersonate_user(user)
    redirect_to root_path
  end

  def stop_impersonating
    stop_impersonating_user
    redirect_to root_path
  end

  def onboarding
    case current_user.onboarding_step
    when 0
      redirect_to '/profile/edit'
    when 1
      redirect_to exercises_path
    when 2
      redirect_to workouts_path
    when 3
      redirect_to macrocycles_path
    when 4
      redirect_to events_path
    when 5
      redirect_to climbs_path
    else
      redirect_to root_path
    end
    current_user.advance_onboarding
  end

  def onboarding_skip
    current_user.advance_onboarding
    respond_to do |format|
      format.js
    end
  end
end
