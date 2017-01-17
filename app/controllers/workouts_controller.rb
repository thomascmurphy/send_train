class WorkoutsController < ApplicationController
  before_filter :set_exercises, :only => [:show, :new, :edit, :update]

  def set_exercises
    @exercises = current_user.exercises
    @boulder_grades = Climb.bouldering_grades(current_user.grade_format)
    @sport_grades = Climb.sport_grades(current_user.grade_format)
  end

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
    @workout = Workout.find_by_id(params[:id])
    if @workout.user.allow_profile_view.blank?
      @workout = nil
    end
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @workout, status: :ok, location: @workout }
    end
  end

  def new
    @workout = current_user.workouts.new
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @workout, status: :created, location: @workout }
    end
  end

  def create
    @workout = current_user.workouts.new(workout_params)

    respond_to do |format|
      if @workout.save
        @workout.handle_workout_exercises(params[:workout_exercises])
        format.html { redirect_to workouts_path, notice: 'Workout was successfully created.' }
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
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @workout, status: :ok, location: @workout }
    end
  end

  def update
    @workout = current_user.workouts.find_by_id(params[:id])
    respond_to do |format|
      if @workout.update_attributes(workout_params)
        @workout.handle_workout_exercises(params[:workout_exercises])
        format.html { redirect_to workouts_path, notice: 'Workout was successfully updated.' }
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

  def duplicate
    @workouts = current_user.workouts.order(created_at: :desc)
    original_workout = Workout.find_by_id(params[:workout_id])
    if original_workout.present? && original_workout.user.allow_profile_view.present?
      @workout = original_workout.duplicate(current_user)
    end
    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end

  def assign_new
    @students = current_user.students
    @workout = current_user.workouts.find_by_id(params[:workout_id])
    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end

  def assign_create
    @workouts = current_user.workouts.order(created_at: :desc)
    @workout = current_user.workouts.find_by_id(params[:workout_id])
    student_ids = current_user.students.pluck(:user_id).uniq
    if params[:student_ids].present?
      params[:student_ids].map(&:to_i).each do |student_id|
        if student_ids.include? student_id
          student = User.find_by_id(student_id)
          new_workout = @workout.duplicate(student)
        end
      end
    end
    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end

  private

  def workout_params
    params.require(:workout).permit(:label, :workout_type, :description, :private)
  end

end
