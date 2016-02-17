class WorkoutsController < ApplicationController

  def index
    @workouts = current_user.workouts.order(created_at: :desc)

    if params[:workout_type].present?
      @workouts = @workouts.where(workout_type: params[:workout_type])
    end

    respond_to do |format|
      format.html
      format.js { render :reload }
      format.json { render json: @workouts, status: :ok, location: @workouts }
    end
  end

  def show
    @workout = current_user.workouts.find_by_id(params[:id])
    @exercises = current_user.exercises
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @workout, status: :ok, location: @workout }
    end
  end

  def new
    @workout = current_user.workouts.new
    @exercises = current_user.exercises
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @workout, status: :created, location: @workout }
    end
  end

  def create
    @workouts = current_user.workouts.order(created_at: :desc)
    @workout = current_user.workouts.new(workout_params)

    respond_to do |format|
      if @workout.save
        @workout.handle_workout_exercises(params[:workout_exercises])
        format.html { redirect_to @workout, notice: 'Workout was successfully created.' }
        format.js
        format.json { render json: @workout, status: :created, location: @workout }
      else
        format.html { render action: "new" }
        format.json { render json: @workout.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @workout = current_user.workouts.find_by_id(params[:id])
    @exercises = current_user.exercises
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @workout, status: :ok, location: @workout }
    end
  end

  def update
    @workout = current_user.workouts.find_by_id(params[:id])
    @exercises = current_user.exercises
    respond_to do |format|
      if @workout.update_attributes(workout_params)
        @workout.handle_workout_exercises(params[:workout_exercises])
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

  def delete
    @workout = current_user.workouts.find_by_id(params[:workout_id])
    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end

  def destroy
    @workouts = current_user.workouts.order(created_at: :desc)
    @workout = current_user.workouts.find_by_id(params[:id])
    @workout.destroy
  end


  private

  def workout_params
    params.require(:workout).permit(:label, :workout_type, :description)
  end

end
