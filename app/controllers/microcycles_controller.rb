class MicrocyclesController < ApplicationController

  def index
    @microcycles = current_user.microcycles.order(created_at: :desc)

    if params[:microcycle_type].present?
      @microcycles = @microcycles.where(microcycle_type: params[:microcycle_type])
    end

    respond_to do |format|
      format.html
      format.js { render :reload }
      format.json { render json: @microcycles, status: :ok, location: @microcycles }
    end
  end

  def show
    @microcycle = current_user.microcycles.find_by_id(params[:id])
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @microcycle, status: :ok, location: @microcycle }
    end
  end

  def new
    @workouts = current_user.workouts.order(created_at: :desc)
    @microcycle = current_user.microcycles.new
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @microcycle, status: :created, location: @microcycle }
    end
  end

  def create
    @microcycles = current_user.microcycles.order(created_at: :desc)
    if params[:microcycle][:workout_ids].present?
      params[:microcycle][:workout_ids] = params[:microcycle][:workout_ids].strip().split(' ')
    end
    if params[:microcycle][:duration_length].present? && params[:microcycle][:duration_unit].present?
      duration = 0
      duration_length = params[:microcycle].delete(:duration_length).to_i
      duration_unit = params[:microcycle].delete(:duration_unit)
      if duration_unit == "weeks"
        duration = duration_length * 604800
      elsif duration_unit == "days"
        duration = duration_length * 86400
      end
      params[:microcycle][:duration] = duration
    end
    @microcycle = current_user.microcycles.new(microcycle_params)
    respond_to do |format|
      if @microcycle.save
        format.html { redirect_to @microcycle, notice: 'Microcycle was successfully created.' }
        format.js
        format.json { render json: @microcycle, status: :created, location: @microcycle }
      else
        format.html { render action: "new" }
        format.json { render json: @microcycle.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @workouts = current_user.workouts.order(created_at: :desc)
    @microcycle = current_user.microcycles.find_by_id(params[:id])
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @microcycle, status: :ok, location: @microcycle }
    end
  end

  def update
    @microcycles = current_user.microcycles.order(created_at: :desc)
    if params[:microcycle][:workout_ids].present?
      params[:microcycle][:workout_ids] = params[:microcycle][:workout_ids].strip().split(' ')
    end
    if params[:microcycle][:duration_length].present? && params[:microcycle][:duration_unit].present?
      duration = 0
      duration_length = params[:microcycle].delete(:duration_length).to_i
      duration_unit = params[:microcycle].delete(:duration_unit)
      if duration_unit == "weeks"
        duration = duration_length * 604800
      elsif duration_unit == "days"
        duration = duration_length * 86400
      end
      params[:microcycle][:duration] = duration
    end
    @microcycle = current_user.microcycles.find_by_id(params[:id])
    respond_to do |format|
      if @microcycle.update_attributes(microcycle_params)
        format.html
        format.js
        format.json { render json: @microcycle, status: :ok, location: @microcycle }
      else
        format.html
        format.js
        format.json { render json: @microcycle.errors, status: :unprocessable_entity }
      end
    end
  end

  def delete
    @microcycle = current_user.microcycles.find_by_id(params[:microcycle_id])
    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end

  def destroy
    @microcycles = current_user.microcycles.order(created_at: :desc)
    @microcycle = current_user.microcycles.find_by_id(params[:id])
    @microcycle.destroy
  end


  private
    def microcycle_params
      params.require(:microcycle).permit(:label, :microcycle_type, :duration, :workout_ids => [])
    end

end
