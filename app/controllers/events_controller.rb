class EventsController < ApplicationController
  before_filter :set_events, :except => [:show, :new, :edit, :delete, :gym_session_new]
  before_filter :set_field_data, :only => [:show, :edit, :self_assessment_new]

  def set_events
    if params[:user_id].present? && params[:user_id].to_i != current_user.id
      user = User.find(params[:user_id])
      @events = user.events
    else
      @events = current_user.events
    end

    monday = DateTime.now.utc.beginning_of_week - 7.days
    @upcoming_weeks = {0=>{}, 1=>{}, 2=>{}}
    for week in 0..2
      for day in 0..6
        date = monday + (day + week * 7).days
        @upcoming_weeks[week][date.strftime("%b %e")] = @events.where("start_date >= ? AND start_date < ? AND (end_date <= ? OR end_date IS NULL)", date.beginning_of_day, date.end_of_day, date.end_of_day).order(start_date: :asc)
      end
    end

    @current_events = @events.where("start_date <= ? AND end_date >= ?", DateTime.now.end_of_day, DateTime.now.beginning_of_day).order(start_date: :asc)
    @upcoming_events = @events.where("start_date > ?", DateTime.now.end_of_day).order(start_date: :asc).limit(20)
    @past_events = @events.where("end_date < ?", DateTime.now.beginning_of_day).order(start_date: :desc).limit(20)
  end

  def set_field_data
    @boulder_grades = Climb.bouldering_grades(current_user.grade_format)
    @sport_grades = Climb.sport_grades(current_user.grade_format)
  end

  def index
    respond_to do |format|
      format.html
      format.js { render :reload }
      format.json { render json: @events, status: :ok, location: @events }
    end
  end

  def show
    @event = Event.find_by_id(params[:id])
    @user = @event.user
    authorized = true
    if @user.id != current_user.id && current_user.students.where(user_id: @user.id).blank?
      authorized = false
    end
    if authorized.present?
      respond_to do |format|
        format.html
        format.js
        format.json { render json: @event, status: :ok, location: @event }
      end
    end
  end

  def new
    if params[:user_id].present?
      @user = User.find(params[:user_id])
    else
      @user = current_user
    end
    @event = @user.events.new
    @user_id = @user.id
    @event.set_dates_to_now
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @event, status: :created, location: @event }
    end
  end

  def create
    start_date_params = params[:start_date]
    if start_date_params.present?
      if start_date_params[:day].present? && start_date_params[:month].present? && start_date_params[:year].present?
        start_date = DateTime.strptime("#{start_date_params[:year]} #{start_date_params[:month]} #{start_date_params[:day]}", "%Y %m %d")
        params[:event][:start_date] = start_date
      end
    end
    end_date_params = params[:end_date]
    if end_date_params.present?
      if end_date_params[:day].present? && end_date_params[:month].present? && end_date_params[:year].present?
        end_date = DateTime.strptime("#{end_date_params[:year]} #{end_date_params[:month]} #{end_date_params[:day]}", "%Y %m %d")
        params[:event][:end_date] = end_date
      end
    end

    if params[:user_id].present? && params[:user_id].to_i != current_user.id
      #Handle a coach creating an event for a student
      @coach_viewing = true
      user = User.find(params[:user_id])
#       if params[:event][:workout_id].present?
#         coach_workout = Workout.find(params[:event][:workout_id])
#         if user.workouts.where(reference_id: params[:event][:workout_id]).present?
#           workout = user.workouts.where(reference_id: params[:event][:workout_id]).first
#         elsif coach_workout.reference_id.present? && user.workouts.where(reference_id: coach_workout.reference_id).present?
#           workout = user.workouts.where(reference_id: coach_workout.reference_id).first
#         else
#           workout = coach_workout.duplicate(user)
#         end
#         params[:event][:workout_id] = workout.id
#       end
#       if params[:event][:macrocycle_id].present?
#         coach_macrocycle = Macrocycle.find(params[:event][:macrocycle_id])
#         if user.macrocycles.where(reference_id: params[:event][:macrocycle_id]).present?
#           macrocycle = user.macrocycles.where(reference_id: params[:event][:macrocycle_id]).first
#         elsif coach_macrocycle.reference_id.present? && user.macrocycles.where(reference_id: coach_macrocycle.reference_id).present?
#           macrocycle = user.macrocycles.where(reference_id: coach_macrocycle.reference_id).first
#         else
#           macrocycle = coach_macrocycle.duplicate(user)
#         end
#         params[:event][:macrocycle_id] = macrocycle.id
#       end
      @event = user.events.new(event_params)
    else
      @event = current_user.events.new(event_params)
    end

    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.js
        format.json { render json: @event, status: :created, location: @event }
      else
        format.html { render action: "new" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    if params[:user_id].present?
      @user = User.find(params[:user_id])
    else
      @user = current_user
    end
    @event = @user.events.find_by_id(params[:id])
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @event, status: :ok, location: @event }
    end
  end

  def update
    @event = current_user.events.find_by_id(params[:id])
    start_date_params = params[:start_date]
    if start_date_params.present?
      if start_date_params[:day].present? && start_date_params[:month].present? && start_date_params[:year].present?
        start_date = DateTime.strptime("#{start_date_params[:year]} #{start_date_params[:month]} #{start_date_params[:day]}", "%Y %m %d")
        params[:event][:start_date] = start_date
      end
    end
    end_date_params = params[:end_date]
    if end_date_params.present?
      if end_date_params[:day].present? && end_date_params[:month].present? && end_date_params[:year].present?
        end_date = DateTime.strptime("#{end_date_params[:year]} #{end_date_params[:month]} #{end_date_params[:day]}", "%Y %m %d")
        params[:event][:end_date] = end_date
      end
    elsif start_date.present? && (start_date > @event.end_date || @event.workout_id.present?)
      @event.end_date = start_date
    end

    if params[:user_id].present? && params[:user_id].to_i != current_user.id
      @coach_viewing = true
    end

    respond_to do |format|
      if @event.update_attributes(event_params)
        @event.handle_exercise_performances(params[:exercise_performances])
        format.html
        format.js
        format.json { render json: @event, status: :ok, location: @event }
      else
        format.html
        format.js
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def delete
    @event = current_user.events.find_by_id(params[:event_id])
    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end

  def destroy
    @event = current_user.events.find_by_id(params[:id])
    @event.destroy
  end

  def complete
    @event = current_user.events.find_by_id(params[:event_id])
    @event.completed = true
    @event.save
    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end

  def gym_session_new
    @event = current_user.events.new
    @event.set_dates_to_now
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @event, status: :created, location: @event }
    end
  end

  def gym_session_create
    start_date = DateTime.now
    start_date_params = params[:start_date]
    if start_date_params.present?
      if start_date_params[:day].present? && start_date_params[:month].present? && start_date_params[:year].present?
        start_date = DateTime.strptime("#{start_date_params[:year]} #{start_date_params[:month]} #{start_date_params[:day]}", "%Y %m %d")
        params[:event][:start_date] = start_date
      end
    end

    if params[:duration].present?
      end_date = start_date + (params[:duration].to_i).hours
      params[:event][:end_date] = end_date
    end

    @event = current_user.events.new(event_params)
    @event.label = "Gym Session"
    if start_date < DateTime.now.end_of_day
      @event.completed = true
    end

    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.js
        format.json { render json: @event, status: :created, location: @event }
      else
        format.html { render action: "new" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def print
    @event = Event.find_by_id(params[:event_id])
    render layout: "print"
  end

  def self_assessment
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

    @workout = Workout.self_assessment_workout

    dates = []
    line_progress = []
    table_progress = []
    if @workout.present?
      @last_self_assessment = current_user.events.where(workout_id: @workout.id, completed: true).last
      @skew_data = @last_self_assessment.quantify(nil, true)
      @skew_data = @skew_data.map{|x| {name: x[:name], value: x[:value], tooltip_value: "#{x[:tooltip_value]}<br/>(~#{x[:climb_grade]})", category: x[:category]}}
      @skew_data_max = @skew_data.map{|x| x[:value]}.max
      sorted_data = @skew_data.sort_by{|x| x[:value]}
      @strongest_aspect = sorted_data.last
      @weakest_aspect = sorted_data.first
      overall = {"Strength": [], "Power": [], "Power Endurance": [], "Endurance": []}.with_indifferent_access
      @skew_data.each do |exercise|
        overall[exercise[:category]] << exercise[:value]
      end
      overall = overall.sort_by{|key, value| value.inject{ |sum, el| sum + el }.to_f / value.size}.to_h
      @weakest_overall = overall.keys.first
      @strongest_overall = overall.keys.last

      @skew_data = @skew_data.to_json

      progress = @workout.progress(nil, @date_lower, @date_upper, current_user.id)
      progress.each do |label, quantifications|
        dates.concat quantifications.map{|q| DateTime.strptime(q[:date], "%b %d, %Y")}
        exercise_progress_line = {'title': label, 'values': []}
        exercise_progress_table = {'title': label, 'values': {}}
        quantifications.each do |quantification|
          exercise_progress_line[:values] << {name: "#{label.capitalize} (#{quantification[:date]})",
                                              value: quantification[:value],
                                              tooltip_value: quantification[:tooltip_value]}

          exercise_progress_table[:values][quantification[:date]] = quantification[:tooltip_value]
        end
        line_progress << exercise_progress_line
        table_progress << exercise_progress_table
      end
    end
    @date_strings = dates.uniq.sort.map{|d| d.strftime("%b %d, %Y")}
    @line_progress = line_progress.to_json
    @table_progress = table_progress

  end

  def self_assessment_new
    workout = Workout.self_assessment_workout(true)
    @event = current_user.events.create(workout_id: workout.id, start_date: DateTime.now)
    @user_id = current_user.id
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @event, status: :created, location: @event }
    end
  end


  private
    def event_params
      params.require(:event).permit(:label, :start_date, :end_date, :event_type,
                                    :perception, :completed, :user_id, :notes,
                                    :workout_id, :microcycle_id, :mesocycle_id,
                                    :macrocycle_id, :parent_event_id, :gym_session)
    end

end
