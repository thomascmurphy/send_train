class CommunityController < ApplicationController
  helper_method :sort_by, :sort_direction, :page, :per_page
  before_filter :set_all_users, :only => [:users, :my_users, :user_follow, :user_unfollow]
  before_filter :set_my_users, :only => [:my_users, :user_follow, :user_unfollow]
  before_filter :set_my_followers, :only => [:my_followers, :user_follow, :user_unfollow]

  def set_all_users
    if sort_by == "follower_count" || sort_by == "workout_count" || sort_by == "name"
      require 'will_paginate/array'
      case sort_by
      when "follower_count"
        @all_users = User.where(allow_profile_view: true).sort_by(&:follower_count)
      when "workout_count"
        @all_users = User.where(allow_profile_view: true).sort_by(&:workout_count)
      when "name"
        @all_users = User.where(allow_profile_view: true).sort_by{|x| x.smart_name.downcase}
      end
      if sort_direction.downcase == "desc"
        @all_users = @all_users.reverse
      end
    else
      @all_users = User.where(allow_profile_view: true).order("#{sort_by} #{sort_direction}", "id ASC")
    end

    @all_users = @all_users.paginate(:page => page, :per_page => per_page)
  end

  def set_my_users
    if sort_by == "follower_count" || sort_by == "workout_count" || sort_by == "name"
      require 'will_paginate/array'
      case sort_by
      when "follower_count"
        @my_users = current_user.my_users.sort_by(&:follower_count)
      when "workout_count"
        @my_users = current_user.my_users.sort_by(&:workout_count)
      when "name"
        @my_users = current_user.my_users.sort_by{|x| x.smart_name.downcase}
      end
      if sort_direction.downcase == "desc"
        @my_users = @my_users.reverse
      end
    else
      @my_users = current_user.my_users.order("#{sort_by} #{sort_direction}", "id ASC")
    end

    @my_users = @my_users.paginate(:page => page, :per_page => per_page)
  end

  def set_my_followers
    if sort_by == "follower_count" || sort_by == "workout_count" || sort_by == "name"
      require 'will_paginate/array'
      case sort_by
      when "follower_count"
        @my_followers = current_user.my_followers.sort_by(&:follower_count)
      when "workout_count"
        @my_followers = current_user.my_followers.sort_by(&:workout_count)
      when "name"
        @my_followers = current_user.my_followers.sort_by{|x| x.smart_name.downcase}
      end
      if sort_direction.downcase == "desc"
        @my_followers = @my_followers.reverse
      end
    else
      @my_followers = current_user.my_followers.order("#{sort_by} #{sort_direction}", "id ASC")
    end

    @my_followers = @my_followers.paginate(:page => page, :per_page => per_page)
  end

  def index
    my_message_ids = current_user.sent_messages.pluck(:id)
    replies = Message.where(parent_message_id: my_message_ids)
    direct_messages = current_user.messages.where(parent_message_id: nil)
    @new_messages = (replies.where(read: false) + direct_messages.where(read: false)).sort_by{|x| [Vote.item_score(x), x.updated_at]}.reverse
    @new_messages = @new_messages.paginate(:page => page, :per_page => per_page)
  end

  def all_messages
    my_message_ids = current_user.sent_messages.pluck(:id)
    replies = Message.where(parent_message_id: my_message_ids)
    direct_messages = current_user.messages.where(parent_message_id: nil)
    @all_messages = (replies + direct_messages).sort_by{|x| [Vote.item_score(x), x.updated_at]}.reverse
    @all_messages = @all_messages.paginate(:page => page, :per_page => per_page)
  end

  def training

  end

  def users

  end

  def my_users

  end

  def my_followers

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

  private

    def sort_by
      legal_sorts = User.column_names + ['workout_count', 'follower_count', 'name']
      legal_sorts.include?(params[:sort_by]) ? params[:sort_by] : "follower_count"
    end

    def sort_direction
      %w[asc desc].include?(params[:sort_direction]) ? params[:sort_direction] : "desc"
    end

    def page
      (params[:page] || 1).to_i
    end

    def per_page
      (params[:per_page] || 20).to_i
    end

end
