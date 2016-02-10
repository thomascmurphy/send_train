class EventsController < ApplicationController

  def index
    if user_signed_in?
      @events = current_user.events

      if params[:event_type].present?
        @events = @events.where(event_type: params[:event_type])
      end

      if params[:event_length].present?
        case params[:event_length]
        when "workout"
          @events = @events.where.not(workout_id: nil)
        when "microcycle"
          @events = @events.where.not(microcycle_id: nil)
        when "mesocycle"
          @events = @events.where.not(mesocycle_id: nil)
        when "macrocycle"
          @events = @events.where.not(macrocycle_id: nil)
        else
        end
      end

      if params[:event_status].present?
        case params[:event_status]
        when "uncompleted"
          @events = @events.where(completed: false)
        when "completed"
          @events = @events.where(completed: true)
        else
        end
      end

      @current_events = @events.where("start_date < ? AND end_date > ?", DateTime.now, DateTime.now).order(start_date: :asc)
      @upcoming_events = @events.where("start_date > ?", DateTime.now).order(start_date: :asc)
      @past_events = @events.where("end_date < ?", DateTime.now).order(start_date: :asc)

      respond_to do |format|
        format.html
        format.js { render :reload }
        format.json { render json: @events, status: :ok, location: @events }
      end
    else
      redirect_to root_path
    end
  end

  def show
    if user_signed_in?
      @event = current_user.events.find_by_id(params[:id])
      respond_to do |format|
        format.html
        format.js
        format.json { render json: @event, status: :ok, location: @event }
      end
    end
  end

  def new
    if user_signed_in?
      @event = current_user.events.new
      respond_to do |format|
        format.html
        format.js
        format.json { render json: @event, status: :created, location: @event }
      end
    end
  end

  def create
    if user_signed_in?
      @events = current_user.events
      @current_events = @events.where("start_date < ? AND end_date > ?", DateTime.now, DateTime.now).order(start_date: :asc)
      @upcoming_events = @events.where("start_date > ?", DateTime.now).order(start_date: :asc)
      @past_events = @events.where("end_date < ?", DateTime.now).order(start_date: :asc)
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

      if event_params[:macrocycle_id].present?
        macrocycle = Macrocycle.find_by_id(event_params[:macrocycle_id])
        if macrocycle.present?
          if macrocycle.duration.present? && start_date.present?
            end_date = start_date + macrocycle.duration.seconds
            params[:event][:end_date] = end_date
          end
        end
      end
      @event = current_user.events.new(event_params)

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
  end

  def edit
    if user_signed_in?
      @event = current_user.events.find_by_id(params[:id])
      respond_to do |format|
        format.html
        format.js
        format.json { render json: @event, status: :ok, location: @event }
      end
    end
  end

  def update
    if user_signed_in?
      @events = current_user.events
      @current_events = @events.where("start_date < ? AND end_date > ?", DateTime.now, DateTime.now).order(start_date: :asc)
      @upcoming_events = @events.where("start_date > ?", DateTime.now).order(start_date: :asc)
      @past_events = @events.where("end_date < ?", DateTime.now).order(start_date: :asc)
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
      @event = current_user.events.find_by_id(params[:id])
      respond_to do |format|
        if @event.update_attributes(event_params)
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
  end

  def delete
    if user_signed_in?
      @event = current_user.events.find_by_id(params[:event_id])
      respond_to do |format|
        format.html
        format.js
        format.json
      end
    end
  end

  def destroy
    if user_signed_in?
      @events = current_user.events
      @current_events = @events.where("start_date < ? AND end_date > ?", DateTime.now, DateTime.now).order(start_date: :asc)
      @upcoming_events = @events.where("start_date > ?", DateTime.now).order(start_date: :asc)
      @past_events = @events.where("end_date < ?", DateTime.now).order(start_date: :asc)
      @event = current_user.events.find_by_id(params[:id])
      @event.destroy
    end
  end

  def complete
    if user_signed_in?
      @event = current_user.events.find_by_id(params[:event_id])
      @event.completed = true
      @event.save
      respond_to do |format|
        format.html
        format.js
        format.json
      end
    end
  end


  private
    def event_params
      params.require(:event).permit(:label, :start_date, :end_date, :event_type,
                                    :perception, :completed, :user_id, :notes,
                                    :workout_id, :microcycle_id, :mesocycle_id,
                                    :macrocycle_id, :parent_event_id)
    end

end
