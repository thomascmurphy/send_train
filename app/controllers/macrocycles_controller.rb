class MacrocyclesController < ApplicationController

  def index
    @macrocycles = current_user.macrocycles.order(created_at: :desc)

    if params[:macrocycle_type].present?
      @macrocycles = @macrocycles.where(macrocycle_type: params[:macrocycle_type])
    end

    respond_to do |format|
      format.html
      format.js { render :reload }
      format.json { render json: @macrocycles, status: :ok, location: @macrocycles }
    end
  end

  def show
    @macrocycle = current_user.macrocycles.find_by_id(params[:id])
    @workouts = current_user.workouts
    @event = @macrocycle.events.first
    @wide_content = true
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @macrocycle, status: :ok, location: @macrocycle }
    end
  end

  def new
    @macrocycle = current_user.macrocycles.new
    @workouts = current_user.workouts
    @event = current_user.events.new
    @wide_content = true
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @macrocycle, status: :created, location: @macrocycle }
    end
  end

  def create
    @macrocycle = current_user.macrocycles.new(macrocycle_params)
    @event = nil
    if @macrocycle.save
      if params[:event][:nice_start_date].present?
        @event = current_user.events.new(macrocycle_id: @macrocycle.id)
        start_date = DateTime.strptime(params[:event][:nice_start_date], '%Y-%m-%d')
        weeks = params[:weeks].present? ? params[:weeks].sort.to_h.keys.last.to_i : 0
        @event.start_date = start_date
        @event.end_date = start_date.end_of_day + weeks.weeks
        @event.save
      end
      @macrocycle.handle_workouts_and_events(params[:weeks], @event)
      respond_to do |format|
        format.html { redirect_to @macrocycle, notice: 'Plan was successfully created.' }
        format.js
        format.json { render json: @macrocycle, status: :created, location: @macrocycle }
      end
    else
      respond_to do |format|
        format.html { render action: "new" }
        format.json { render json: @macrocycle.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @macrocycle = current_user.macrocycles.find_by_id(params[:id])
    @workouts = current_user.workouts
    @event = @macrocycle.events.new
    @wide_content = true
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @macrocycle, status: :ok, location: @macrocycle }
    end
  end

  def update
    @macrocycle = current_user.macrocycles.find_by_id(params[:id])
    @event = nil
    if @macrocycle.update_attributes(macrocycle_params)
      if params[:event][:nice_start_date].present?
        @event = current_user.events.new(macrocycle_id: @macrocycle.id)
        start_date = DateTime.strptime(params[:event][:nice_start_date], '%Y-%m-%d')
        weeks = params[:weeks].present? ? params[:weeks].sort.to_h.keys.last.to_i : 0
        @event.start_date = start_date
        @event.end_date = start_date.end_of_day + weeks.weeks
        @event.save
      end
      @macrocycle.handle_workouts_and_events(params[:weeks], @event)
      respond_to do |format|
        format.html { redirect_to @macrocycle, notice: 'Plan was successfully updated.' }
        format.js
        format.json { render json: @macrocycle, status: :created, location: @macrocycle }
      end
    else
      respond_to do |format|
        format.html { render action: "new" }
        format.json { render json: @macrocycle.errors, status: :unprocessable_entity }
      end
    end
  end

  def delete
    @macrocycle = current_user.macrocycles.find_by_id(params[:macrocycle_id])
    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end

  def destroy
    @macrocycles = current_user.macrocycles.order(created_at: :desc)
    @macrocycle = current_user.macrocycles.find_by_id(params[:id])
    @macrocycle.destroy
  end


  private
    def macrocycle_params
      params.require(:macrocycle).permit(:label, :macrocycle_type, :mesocycle_ids => [])
    end

end
