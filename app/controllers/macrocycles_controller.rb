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
    @macrocycle = Macrocycle.find_by_id(params[:id])
    if @macrocycle.user.allow_profile_view.blank? && @macrocycle.user.id != current_user.id
      @macrocycle = nil
    end
    if @macrocycle.present?
      respond_to do |format|
        format.html
        format.js
        format.json { render json: @macrocycle, status: :ok, location: @macrocycle }
      end
    else
      redirect_to macrocycles_path , notice: 'That plan does not exist'
    end
  end

  def new
    @macrocycle = current_user.macrocycles.new
    @workouts = current_user.workouts
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
      @macrocycle.handle_workouts(params[:weeks])
      start_date_params = params[:start_date]
      if params[:add_events].present? && start_date_params.present?
        if start_date_params[:day].present? && start_date_params[:month].present? && start_date_params[:year].present?
          start_date = DateTime.strptime("#{start_date_params[:year]} #{start_date_params[:month]} #{start_date_params[:day]}", "%Y %m %d")
          @event = current_user.events.new(macrocycle_id: @macrocycle.id)
          weeks = params[:weeks].present? ? params[:weeks].sort.to_h.keys.last.to_i : 0
          @event.start_date = start_date
          @event.end_date = start_date.end_of_day + weeks.weeks
          @event.save
        end
      end
      respond_to do |format|
        if params[:add_events].present?
          format.html { redirect_to events_path, notice: 'Events were successfully created.' }
        else
          format.html { redirect_to macrocycles_path, notice: 'Plan was successfully created.' }
        end
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
    if @macrocycle.present?
      @workouts = current_user.workouts
      @wide_content = true
      respond_to do |format|
        format.html
        format.js
        format.json { render json: @macrocycle, status: :ok, location: @macrocycle }
      end
    else
      redirect_to macrocycles_path, notice: 'That plan does not exist'
    end
  end

  def update
    @macrocycle = current_user.macrocycles.find_by_id(params[:id])
    if @macrocycle.present?
      @event = nil
      if @macrocycle.update_attributes(macrocycle_params)
        @macrocycle.handle_workouts(params[:weeks])
        start_date_params = params[:start_date]
        if params[:add_events].present? && start_date_params.present?
          if start_date_params[:day].present? && start_date_params[:month].present? && start_date_params[:year].present?
            start_date = DateTime.strptime("#{start_date_params[:year]} #{start_date_params[:month]} #{start_date_params[:day]}", "%Y %m %d")
            @event = current_user.events.new(macrocycle_id: @macrocycle.id)
            weeks = params[:weeks].present? ? params[:weeks].sort.to_h.keys.last.to_i : 0
            @event.start_date = start_date
            @event.end_date = start_date.end_of_day + weeks.weeks
            @event.save
          end
        end
        respond_to do |format|
          if params[:add_events].present?
            format.html { redirect_to events_path, notice: 'Events were successfully created.' }
          else
            format.html { redirect_to macrocycles_path, notice: 'Plan was successfully updated.' }
          end
          format.js
          format.json { render json: @macrocycle, status: :created, location: @macrocycle }
        end
      else
        respond_to do |format|
          format.html { render action: "new" }
          format.json { render json: @macrocycle.errors, status: :unprocessable_entity }
        end
      end
    else
      redirect_to macrocycles_path, notice: 'That plan does not exist'
    end
  end

  def delete
    @macrocycle = current_user.macrocycles.find_by_id(params[:macrocycle_id])
    if @macrocycle.present?
      respond_to do |format|
        format.html
        format.js
        format.json
      end
    else
      redirect_to macrocycles_path, notice: 'That plan does not exist'
    end
  end

  def destroy
    @macrocycles = current_user.macrocycles.order(created_at: :desc)
    @macrocycle = current_user.macrocycles.find_by_id(params[:id])
    if @macrocycle.present?
      @macrocycle.destroy
    else
      redirect_to macrocycles_path, notice: 'That plan does not exist'
    end
  end

  def duplicate
    @macrocycles = current_user.macrocycles.order(created_at: :desc)
    original_macrocycle = Macrocycle.find_by_id(params[:macrocycle_id])
    if original_macrocycle.present? && (original_macrocycle.user.allow_profile_view.present? || original_macrocycle.user.id == current_user.id)
      @macrocycle = original_macrocycle.duplicate(current_user)
    end
    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end

  def assign_new
    @students = current_user.students
    @macrocycle = current_user.macrocycles.find_by_id(params[:macrocycle_id])
    respond_to do |format|
      format.html
      format.js
      format.json
    end
  end

  def assign_create
    @macrocycles = current_user.macrocycles.order(created_at: :desc)
    @macrocycle = current_user.macrocycles.find_by_id(params[:macrocycle_id])
    student_ids = current_user.students.pluck(:user_id).uniq
    if params[:student_ids].present?
      params[:student_ids].map(&:to_i).each do |student_id|
        if student_ids.include? student_id
          student = User.find_by_id(student_id)
          new_macrocycle = @macrocycle.duplicate(student)
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

  def macrocycle_params
    params.require(:macrocycle).permit(:label, :macrocycle_type, :private, :mesocycle_ids => [])
  end

end
