class ProfileController < ApplicationController
  def show
    @user = current_user
    @next_events = current_user.events.where("start_date <= ? AND end_date >= ?", DateTime.now.end_of_day, DateTime.now.beginning_of_day).where.not(workout_id: nil, completed: true).order(start_date: :asc).first(2)
    @best_workouts_bouldering = current_user.workouts.sort_by{|w| w.efficacy("boulder")}.reverse[0..1]
    @best_workouts_sport_climbing = current_user.workouts.sort_by{|w| w.efficacy("sport")}.reverse[0..1]
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
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def progress
    @workout = nil
    @climb_data = nil
    @show_climbs = params[:show_climbs]
    if params[:workout_id].present?
      @workout = current_user.workouts.find_by_id(params[:workout_id])
      progress = @workout.progress
      formatted_progress = []
      progress.each do |hold, quantifications|
        hold_progress = []
        quantifications.each do |quantification|
          hold_progress << {name: "#{hold.capitalize} #{quantification[:date]}",
                            value: quantification[:value],
                            tooltip_value: quantification[:value]}
        end
        formatted_progress << hold_progress
      end
      @workout_progress = formatted_progress.to_json
    end
    @user = current_user
    if @show_climbs.present? && @user.should_show_climb_data?
      @climb_data = @user.profile_graph_data.to_json
    end
    respond_to do |format|
      format.html
      format.js { render :reload }
      format.json { render json: @workout_progress, status: :ok }
    end
  end

  private

  def profile_params
    params.require(:user).permit(:first_name, :last_name, :grade_format,
                                 :birthdate, :climbing_start_date, :default_length_unit,
                                 :default_weight_unit, :gym_name, :accept_shares)
  end

end
