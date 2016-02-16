class UsersController < ApplicationController
  before_filter :require_admin!

  def require_admin!
    unless true_user.is_admin?
      redirect_to root_path, notice: 'You aint qualified fool!'
    end
  end

  def index
    @users = User.all
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
end
