class EventsController < ApplicationController
  before_filter :set_events, :except => [:show, :new, :edit, :delete, :gym_session_new]
  before_filter :set_field_data, :only => [:show, :edit]

  def set_events
    if params[:user_id].present? && params[:user_id] != current_user.id
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
    @upcoming_events = @events.where("start_date > ?", DateTime.now.end_of_day).order(start_date: :asc)
    @past_events = @events.where("end_date < ?", DateTime.now.beginning_of_day).order(start_date: :desc)
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
      user = User.find(params[:user_id])
    else
      user = current_user
    end
    @event = user.events.new
    @user_id = user.id
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

    if params[:user_id].present? && params[:user_id] != current_user.id
      #Handle a coach creating an event for a student
      @coach_viewing = true
      user = User.find(params[:user_id])
      if params[:event][:workout_id].present?
        coach_workout = Workout.find(params[:event][:workout_id])
        if user.workouts.where(reference_id: params[:event][:workout_id]).present?
          workout = user.workouts.where(reference_id: params[:event][:workout_id]).first
        elsif coach_workout.reference_id.present? && user.workouts.where(reference_id: coach_workout.reference_id).present?
          workout = user.workouts.where(reference_id: coach_workout.reference_id).first
        else
          workout = coach_workout.duplicate(user)
        end
        params[:event][:workout_id] = workout.id
      end
      if params[:event][:macrocycle_id].present?
        coach_macrocycle = Macrocycle.find(params[:event][:macrocycle_id])
        if user.macrocycles.where(reference_id: params[:event][:macrocycle_id]).present?
          macrocycle = user.macrocycles.where(reference_id: params[:event][:macrocycle_id]).first
        elsif coach_macrocycle.reference_id.present? && user.macrocycles.where(reference_id: coach_macrocycle.reference_id).present?
          macrocycle = user.macrocycles.where(reference_id: coach_macrocycle.reference_id).first
        else
          macrocycle = coach_macrocycle.duplicate(user)
        end
        params[:event][:macrocycle_id] = macrocycle.id
      end
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
    @event = current_user.events.find_by_id(params[:id])
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


  private
    def event_params
      params.require(:event).permit(:label, :start_date, :end_date, :event_type,
                                    :perception, :completed, :user_id, :notes,
                                    :workout_id, :microcycle_id, :mesocycle_id,
                                    :macrocycle_id, :parent_event_id, :gym_session)
    end

end
