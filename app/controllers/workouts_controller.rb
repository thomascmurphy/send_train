class WorkoutsController < ApplicationController

  def index
    if user_signed_in?
      @workouts = current_user.workouts.order(created_at: :desc)

      if params[:workout_type].present?
        @workouts = @workouts.where(workout_type: params[:workout_type])
      end

      respond_to do |format|
        format.html
        format.js { render :reload }
        format.json { render json: @workouts, status: :ok, location: @workouts }
      end
    else
      redirect_to root_path
    end
  end

  def show
    if user_signed_in?
      @workout = current_user.workouts.find_by_id(params[:id])
      respond_to do |format|
        format.html
        format.js
        format.json { render json: @workout, status: :ok, location: @workout }
      end
    end
  end

  def new
    if user_signed_in?
      @workout = current_user.workouts.new
      respond_to do |format|
        format.html
        format.js
        format.json { render json: @workout, status: :created, location: @workout }
      end
    end
  end

  def create
    if user_signed_in?
      @workouts = current_user.workouts.order(created_at: :desc)
      @workout = current_user.workouts.new(workout_params)

      respond_to do |format|
        if @workout.save
          format.html { redirect_to @workout, notice: 'Workout was successfully created.' }
          format.js
          format.json { render json: @workout, status: :created, location: @workout }
        else
          format.html { render action: "new" }
          format.json { render json: @workout.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def edit
    if user_signed_in?
      @workout = current_user.workouts.find_by_id(params[:id])
      respond_to do |format|
        format.html
        format.js
        format.json { render json: @workout, status: :ok, location: @workout }
      end
    end
  end

  def update
    if user_signed_in?
      @workouts = current_user.workouts.order(created_at: :desc)
      @workout = current_user.workouts.find_by_id(params[:id])
      respond_to do |format|
        if @workout.update_attributes(workout_params)
          format.html
          format.js
          format.json { render json: @workout, status: :ok, location: @workout }
        else
          format.html
          format.js
          format.json { render json: @workout.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def delete
    if user_signed_in?
      @workout = current_user.workouts.find_by_id(params[:workout_id])
      respond_to do |format|
        format.html
        format.js
        format.json
      end
    end
  end

  def destroy
    if user_signed_in?
      @workouts = current_user.workouts.order(created_at: :desc)
      @workout = current_user.workouts.find_by_id(params[:id])
      @workout.destroy
    end
  end


  private
    def workout_params
      params.require(:workout).permit(:label, :workout_type, :description)
    end

end
