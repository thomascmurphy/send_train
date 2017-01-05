class CommunityController < ApplicationController
  before_filter :set_users, :only => [:users, :user_follow, :user_unfollow]

  def set_users
    if params[:show_my_users] == "true"
      @users = current_user.my_users
    else
      @users = User.where(allow_profile_view: true).sort_by(&:follower_count).reverse
    end
  end

  def index

  end

  def training

  end

  def users

  end

  def my_users
    @users = current_user.my_users
  end

  def user
    @user = User.find_by_id(params[:user_id])
  end

  def user_follow
    user = User.find_by_id(params[:user_id])
    if user.present? && user.allow_followers.present? && current_user.is_following(params[:user_id]).blank?
      @user_follower = UserFollower.new(user_id: params[:user_id], follower_id: current_user.id)
      respond_to do |format|
        if @user_follower.save
          format.html { redirect_to @user_follower, notice: 'User was successfully followed.' }
          format.js
          format.json { render json: @user_follower, status: :created, location: @user_follower }
        else
          format.html { render action: "new" }
          format.json { render json: @user_follower.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html
        format.js
        format.json { render json: @user_follower.errors, status: :unprocessable_entity }
      end
    end
  end

  def user_unfollow
    @user_follower = UserFollower.where(user_id: params[:user_id], follower_id: current_user.id)
    if @user_follower.present?
      @user_follower.destroy_all
    end
  end

end
