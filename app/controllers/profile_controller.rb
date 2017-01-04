class ProfileController < ApplicationController
  def show
    @user = current_user
    @next_events = current_user.events.where("start_date <= ? AND end_date >= ?", DateTime.now.end_of_day, DateTime.now.beginning_of_day).where.not(workout_id: nil, completed: true).order(start_date: :asc).first(2)
    @best_workouts_bouldering = current_user.workouts.sort_by{|w| w.efficacy("boulder")}.reverse[0..1]
    @best_workouts_sport_climbing = current_user.workouts.sort_by{|w| w.efficacy("sport")}.reverse[0..1]
    @ongoing_goals = Goal.where(user_id: current_user.id, parent_goal_id: nil, completed: false)
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    birthdate_params = params[:birthdate]
    if birthdate_params.present?
      if birthdate_params[:day].present? && birthdate_params[:month].present? && birthdate_params[:year].present?
        birthdate = DateTime.strptime("#{birthdate_params[:year]} #{birthdate_params[:month]} #{birthdate_params[:day]}", "%Y %m %d")
        if DateTime.now - birthdate > 360
          params[:user][:birthdate] = birthdate
        end
      end
    end
    climbing_start_date_params = params[:climbing_start_date]
    if climbing_start_date_params.present?
      if climbing_start_date_params[:day].present? && climbing_start_date_params[:month].present? && climbing_start_date_params[:year].present?
        climbing_start_date = DateTime.strptime("#{climbing_start_date_params[:year]} #{climbing_start_date_params[:month]} #{climbing_start_date_params[:day]}", "%Y %m %d")
        if DateTime.now - climbing_start_date > 10
          params[:user][:climbing_start_date] = climbing_start_date
        end
      end
    end

    respond_to do |format|
      if @user.update_attributes(profile_params)
        format.html { redirect_to profile_path, notice: 'Profile was successfully updated.' }
        format.js
        format.json { render json: @user, status: :ok, location: @user }
      else
        format.html { render action: "edit", notice: 'Something\'s wrong.' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def progress
    if params[:user_id].present? && current_user.students.where(user_id: params[:user_id]).present?
      @user = User.find_by_id(params[:user_id])
    else
      @user = current_user
    end
    @workout = nil
    @climb_data = nil
    @show_climbs = params[:show_climbs]
    @filter_workout_exercise_ids = params[:workout_exercise_ids].present? ? params[:workout_exercise_ids].map(&:to_i) : nil
    date_params = params[:date]
    if date_params.present?
      if date_params[:day_lower].present? && date_params[:month_lower].present? && date_params[:year_lower].present?
        @date_lower = DateTime.strptime("#{date_params[:year_lower]} #{date_params[:month_lower]} #{date_params[:day_lower]}", "%Y %m %d")
      end
      if date_params[:day_upper].present? && date_params[:month_upper].present? && date_params[:year_upper].present?
        @date_upper = DateTime.strptime("#{date_params[:year_upper]} #{date_params[:month_upper]} #{date_params[:day_upper]}", "%Y %m %d").end_of_day
      end
    else
      @date_lower = DateTime.now - 3.month;
      @date_upper = DateTime.now;
    end

    dates = []
    if params[:workout_id].present?
      @workout = @user.workouts.find_by_id(params[:workout_id])
      formatted_progress = []
      table_progress = []
      if @workout.present?
        progress = @workout.progress(@filter_workout_exercise_ids, @date_lower, @date_upper)
        progress.each do |label, quantifications|
          dates.concat quantifications.map{|q| DateTime.strptime(q[:date], "%b %d, %Y")}
          hold_progress = {'title': label, 'values': []}
          hold_progress_table = {'title': label, 'values': {}}
          quantifications.each do |quantification|
            hold_progress[:values] << {name: "#{label.capitalize} (#{quantification[:date]})",
                                       value: quantification[:value],
                                       tooltip_value: quantification[:tooltip_value]}

            hold_progress_table[:values][quantification[:date]] = quantification[:tooltip_value]
          end
          formatted_progress << hold_progress
          table_progress << hold_progress_table
        end
      end
      @date_strings = dates.uniq.sort.map{|d| d.strftime("%b %d, %Y")}
      @workout_progress = formatted_progress.to_json
      @table_progress = table_progress
    end
    if @show_climbs.present? && @user.should_show_climb_data?
      if dates.present?
        @climb_data = @user.climb_graph_data_for_dates(dates.uniq).to_json
      else
        @climb_data = @user.climb_graph_data.to_json
      end
    end
    respond_to do |format|
      format.html {
        if params[:user_id].present? && params[:user_id].to_i != @user.id
          redirect_to profile_progress_path
        end
      }
      format.js { render :reload }
      format.json { render json: @workout_progress, status: :ok }
    end
  end

  def schedule
    if params[:user_id].present? && current_user.students.where(user_id: params[:user_id]).present?
      @user = User.find_by_id(params[:user_id])
    else
      redirect_to events_path
    end
    @events = @user.events
    monday = DateTime.now.utc.beginning_of_week - 7.days
    @upcoming_weeks = {0=>{}, 1=>{}, 2=>{}}
    for week in 0..2
      for day in 0..6
        date = monday + (day + week * 7).days
        @upcoming_weeks[week][date.strftime("%b %e")] = @events.where("start_date >= ? AND start_date < ? AND (end_date <= ? OR end_date IS NULL)", date.beginning_of_day, date.end_of_day, date.end_of_day).order(start_date: :asc)
      end
    end

    @current_events = @events.where("start_date <= ? AND end_date >= ?", DateTime.now.end_of_day, DateTime.now.beginning_of_day).order(start_date: :asc)
    @upcoming_events = @events.where("start_date > ?", DateTime.now.end_of_day).order(start_date: :asc)
    @past_events = @events.where("end_date < ?", DateTime.now.beginning_of_day).order(start_date: :desc)
  end

  private

  def profile_params
    params.require(:user).permit(:first_name, :last_name, :grade_format,
                                 :birthdate, :climbing_start_date, :default_length_unit,
                                 :default_weight_unit, :gym_name, :accept_shares,
                                 :handle, :allow_profile_view, :allow_followers,
                                 :weight, :weight_unit)
  end

end
