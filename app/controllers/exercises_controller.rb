class ExercisesController < ApplicationController

  def index
    @exercises = current_user.exercises.order(created_at: :desc)

    if params[:exercise_type].present?
      @exercises = @exercises.where(exercise_type: params[:exercise_type])
    end

    respond_to do |format|
      format.html
      format.js { render :reload }
      format.json { render json: @exercises, status: :ok, location: @exercises }
    end
  end

  def show
    @exercise = current_user.exercises.find_by_id(params[:id])
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @exercise, status: :ok, location: @exercise }
    end
  end

  def new
    @exercise = current_user.exercises.new
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @exercise, status: :created, location: @exercise }
    end
  end

  def create
    @exercises = current_user.exercises.order(created_at: :desc)
    @exercise = current_user.exercises.new(exercise_params)

    respond_to do |format|
      if @exercise.save
        format.html { redirect_to @exercise, notice: 'Exercise was successfully created.' }
        format.js
        format.json { render json: @exercise, status: :created, location: @exercise }
      else
        format.html { render action: "new" }
        format.json { render json: @exercise.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @exercise = current_user.exercises.find_by_id(params[:id])
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @exercise, status: :ok, location: @exercise }
    end
  end

  def update
    @exercises = current_user.exercises.order(created_at: :desc)
    @exercise = current_user.exercises.find_by_id(params[:id])
    respond_to do |format|
      if @exercise.update_attributes(exercise_params)
        @exercise.handle_exercise_metrics(params[:exercise_metrics])
        format.html
        format.js
        format.json { render json: @exercise, status: :ok, location: @exercise }
      else
        format.html
        format.js
        format.json { render json: @exercise.errors, status: :unprocessable_entity }
      end
    end
  end

  def delete
    @exercise = current_user.exercises.find_by_id(params[:exercise_id])
    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end

  def destroy
    @exercises = current_user.exercises.order(created_at: :desc)
    @exercise = current_user.exercises.find_by_id(params[:id])
    @exercise.destroy
  end


  private

  def exercise_params
    params.require(:exercise).permit(:label, :exercise_type, :description)
  end
end
